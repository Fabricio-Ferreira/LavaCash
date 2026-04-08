-- =========================================================================
-- 007_empresa_usuarios_policies_no_self_subquery.sql
-- Policies that use EXISTS (SELECT ... FROM empresa_usuarios eu ...) force
-- a second RLS pass on the same table; combined with get_empresa_id() this
-- can still hit recursion (42P17) depending on evaluation order.
-- Use get_my_role() instead (reads empresa_usuarios with row_security off).
-- Idempotent: repeats helper definitions from 006 so remote DBs stay fixed.
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

DROP POLICY IF EXISTS "empresa_usuarios_admin_write" ON public.empresa_usuarios;

CREATE POLICY "empresa_usuarios_admin_write" ON public.empresa_usuarios
  FOR ALL
  USING (
    empresa_id = public.get_empresa_id()
    AND public.get_my_role() = 'admin'
  )
  WITH CHECK (
    empresa_id = public.get_empresa_id()
    AND public.get_my_role() = 'admin'
  );

DROP POLICY IF EXISTS "convites_admin_all" ON public.empresa_convites;

CREATE POLICY "convites_admin_all" ON public.empresa_convites
  FOR ALL
  USING (
    empresa_id = public.get_empresa_id()
    AND public.get_my_role() = 'admin'
  )
  WITH CHECK (
    empresa_id = public.get_empresa_id()
    AND public.get_my_role() = 'admin'
  );
