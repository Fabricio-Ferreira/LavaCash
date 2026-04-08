-- =========================================================================
-- 009_list_empresa_usuarios_enriched_email.sql
-- Adds user_email and extra metadata keys so operador/admin labels resolve
-- the same way (nome preferencial, senão email, etc.).
-- REPLACE cannot change RETURNS TABLE shape — must DROP first.
-- =========================================================================

DROP FUNCTION IF EXISTS public.list_empresa_usuarios_enriched(uuid);

CREATE OR REPLACE FUNCTION public.list_empresa_usuarios_enriched(
  p_empresa_id uuid
)
RETURNS TABLE (
  id uuid,
  empresa_id uuid,
  user_id uuid,
  role text,
  created_at timestamptz,
  display_name text,
  user_email text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT
    eu.id,
    eu.empresa_id,
    eu.user_id,
    eu.role,
    eu.created_at,
    COALESCE(
      NULLIF(trim(au.raw_user_meta_data->>'full_name'), ''),
      NULLIF(trim(au.raw_user_meta_data->>'name'), ''),
      NULLIF(trim(au.raw_user_meta_data->>'nickname'), ''),
      NULLIF(trim(au.raw_user_meta_data->>'preferred_username'), ''),
      NULLIF(trim(split_part(au.email, '@', 1)), '')
    ) AS display_name,
    au.email::text AS user_email
  FROM public.empresa_usuarios eu
  INNER JOIN auth.users au ON au.id = eu.user_id
  WHERE eu.empresa_id = p_empresa_id
    AND EXISTS (
      SELECT 1
      FROM public.empresa_usuarios m
      WHERE m.empresa_id = p_empresa_id
        AND m.user_id = auth.uid()
    )
  ORDER BY eu.created_at;
$$;

GRANT EXECUTE ON FUNCTION public.list_empresa_usuarios_enriched(uuid)
  TO authenticated;
