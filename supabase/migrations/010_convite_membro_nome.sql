-- =========================================================================
-- 010_convite_membro_nome.sql
-- - empresa_convites.membro_nome: nome do funcionário (operador) no convite.
-- - empresa_usuarios.membro_nome: copiado na aceitação; listagem usa admin →
--   nome do estabelecimento (empresas.nome), operador → membro_nome c/ fallback.
-- =========================================================================

ALTER TABLE public.empresa_convites
  ADD COLUMN IF NOT EXISTS membro_nome TEXT;

ALTER TABLE public.empresa_usuarios
  ADD COLUMN IF NOT EXISTS membro_nome TEXT;

COMMENT ON COLUMN public.empresa_convites.membro_nome IS
  'Nome do funcionário quando o convite é para operador.';
COMMENT ON COLUMN public.empresa_usuarios.membro_nome IS
  'Nome exibido para operador; admins usam empresas.nome na listagem.';

-- ---------------------------------------------------------------------------
-- accept_empresa_convite: persist membro_nome on empresa_usuarios (operador)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.accept_empresa_convite(TEXT);

CREATE OR REPLACE FUNCTION public.accept_empresa_convite(p_activation_code TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  v_empresa_id   UUID;
  v_role         TEXT;
  v_membro_nome  TEXT;
BEGIN
  UPDATE public.empresa_convites
  SET    claimed_at = now()
  WHERE  activation_code = p_activation_code
    AND  claimed_at      IS NULL
  RETURNING empresa_id, role, membro_nome
  INTO    v_empresa_id, v_role, v_membro_nome;

  IF v_empresa_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO public.empresa_usuarios (empresa_id, user_id, role, membro_nome)
  VALUES (
    v_empresa_id,
    auth.uid(),
    v_role,
    CASE
      WHEN v_role = 'operador' THEN NULLIF(trim(v_membro_nome), '')
      ELSE NULL
    END
  )
  ON CONFLICT (empresa_id, user_id) DO NOTHING;

  RETURN v_empresa_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_empresa_convite(TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- list_empresa_usuarios_enriched: admin → estabelecimento; operador → membro
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.list_empresa_usuarios_enriched(UUID);

CREATE OR REPLACE FUNCTION public.list_empresa_usuarios_enriched(
  p_empresa_id UUID
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
    CASE eu.role
      WHEN 'admin' THEN e.nome
      ELSE COALESCE(
        NULLIF(trim(eu.membro_nome), ''),
        NULLIF(trim(au.raw_user_meta_data->>'full_name'), ''),
        NULLIF(trim(au.raw_user_meta_data->>'name'), ''),
        NULLIF(trim(au.raw_user_meta_data->>'nickname'), ''),
        NULLIF(trim(au.raw_user_meta_data->>'preferred_username'), ''),
        NULLIF(trim(split_part(au.email, '@', 1)), '')
      )
    END AS display_name,
    au.email::text AS user_email
  FROM public.empresa_usuarios eu
  INNER JOIN auth.users au ON au.id = eu.user_id
  INNER JOIN public.empresas e ON e.id = eu.empresa_id
  WHERE eu.empresa_id = p_empresa_id
    AND EXISTS (
      SELECT 1
      FROM public.empresa_usuarios m
      WHERE m.empresa_id = p_empresa_id
        AND m.user_id = auth.uid()
    )
  ORDER BY eu.created_at;
$$;

GRANT EXECUTE ON FUNCTION public.list_empresa_usuarios_enriched(UUID)
  TO authenticated;
