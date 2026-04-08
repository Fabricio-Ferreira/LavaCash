-- =========================================================================
-- 008_list_empresa_usuarios_enriched.sql
-- Returns empresa_usuarios rows with a display label from auth.users
-- (metadata or email local-part). Caller must be a member of p_empresa_id.
-- =========================================================================

CREATE OR REPLACE FUNCTION public.list_empresa_usuarios_enriched(
  p_empresa_id uuid
)
RETURNS TABLE (
  id uuid,
  empresa_id uuid,
  user_id uuid,
  role text,
  created_at timestamptz,
  display_name text
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
      NULLIF(trim(split_part(au.email, '@', 1)), '')
    ) AS display_name
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
