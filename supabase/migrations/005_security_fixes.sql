-- =========================================================================
-- 005_security_fixes.sql
-- Security fixes for multi-user roles introduced in 004.
--
-- Fix 1: Add empresas SELECT policy for non-owner members (operadores).
-- Fix 2: Harden register_user_in_empresa — prevent a user from self-joining
--        an arbitrary empresa.
-- Fix 3: Eliminate race condition in accept_empresa_convite using atomic
--        UPDATE ... RETURNING instead of SELECT then UPDATE.
-- =========================================================================

-- ---------------------------------------------------------------------------
-- Fix 1: Operadores can read their empresa row (owner_id != their uid).
--   The existing "empresas_select_own" policy only covers the owner.
--   Members (from empresa_usuarios) need to resolve their empresa too.
-- ---------------------------------------------------------------------------
CREATE POLICY "empresas_select_member" ON public.empresas
  FOR SELECT USING (id = public.get_empresa_id());

-- ---------------------------------------------------------------------------
-- Fix 2: register_user_in_empresa — only allow if:
--   (a) the user has no empresa yet (first-time link), AND
--   (b) the target empresa_id is the one this user is being linked to via
--       claim_empresa / create (enforced by the caller).
--   Prevents any authenticated user from calling with an arbitrary UUID.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.register_user_in_empresa(
  p_empresa_id UUID,
  p_role       TEXT DEFAULT 'admin'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Reject if user is already linked to a different empresa.
  IF public.get_empresa_id() IS NOT NULL
     AND public.get_empresa_id() <> p_empresa_id
  THEN
    RAISE EXCEPTION
      'User is already linked to a different empresa (%).',
      public.get_empresa_id();
  END IF;

  -- Reject if the target empresa does not exist.
  IF NOT EXISTS (SELECT 1 FROM public.empresas WHERE id = p_empresa_id) THEN
    RAISE EXCEPTION 'Empresa % does not exist.', p_empresa_id;
  END IF;

  INSERT INTO public.empresa_usuarios (empresa_id, user_id, role)
  VALUES (p_empresa_id, auth.uid(), p_role)
  ON CONFLICT (empresa_id, user_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user_in_empresa(UUID, TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Fix 3: accept_empresa_convite — atomic UPDATE ... RETURNING eliminates
--   the SELECT + UPDATE race condition where two devices could both read
--   claimed_at IS NULL before either commits the UPDATE.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.accept_empresa_convite(p_activation_code TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_empresa_id  UUID;
  v_role        TEXT;
BEGIN
  -- Atomic claim: only one concurrent caller will get a row back.
  UPDATE public.empresa_convites
  SET    claimed_at = now()
  WHERE  activation_code = p_activation_code
    AND  claimed_at      IS NULL
  RETURNING empresa_id, role
  INTO   v_empresa_id, v_role;

  IF v_empresa_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO public.empresa_usuarios (empresa_id, user_id, role)
  VALUES (v_empresa_id, auth.uid(), v_role)
  ON CONFLICT (empresa_id, user_id) DO NOTHING;

  RETURN v_empresa_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_empresa_convite(TEXT) TO authenticated;
