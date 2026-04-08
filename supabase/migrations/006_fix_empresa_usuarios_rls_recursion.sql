-- =========================================================================
-- 006_fix_empresa_usuarios_rls_recursion.sql
-- Policies on empresa_usuarios use get_empresa_id(). That function SELECTs
-- empresa_usuarios; with default row_security=on, RLS re-evaluates the same
-- policies → "infinite recursion detected in policy".
-- SET row_security = off on SECURITY DEFINER helpers is the supported fix;
-- both functions still filter by auth.uid(), so tenant isolation holds.
-- =========================================================================

CREATE OR REPLACE FUNCTION public.get_empresa_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT empresa_id
  FROM   public.empresa_usuarios
  WHERE  user_id = auth.uid()
  LIMIT  1
$$;

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT role
  FROM   public.empresa_usuarios
  WHERE  user_id = auth.uid()
  LIMIT  1
$$;
