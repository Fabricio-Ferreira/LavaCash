-- Replace get_empresa_id() equality in RLS with ownership subqueries.
-- SECURITY DEFINER get_empresa_id() inside policy WITH CHECK can fail inserts
-- in some Postgres/RLS evaluation orders; IN (SELECT ... WHERE owner_id = auth.uid())
-- uses the same tenant rule with invoker-visible empresas rows.

DROP POLICY IF EXISTS "clientes_empresa" ON public.clientes;
DROP POLICY IF EXISTS "veiculos_empresa" ON public.veiculos;
DROP POLICY IF EXISTS "atendimentos_empresa" ON public.atendimentos;

-- Idempotent: production may already have *_tenant policies (same rules).
DROP POLICY IF EXISTS "clientes_select_tenant" ON public.clientes;
DROP POLICY IF EXISTS "clientes_insert_tenant" ON public.clientes;
DROP POLICY IF EXISTS "clientes_update_tenant" ON public.clientes;
DROP POLICY IF EXISTS "clientes_delete_tenant" ON public.clientes;
DROP POLICY IF EXISTS "veiculos_select_tenant" ON public.veiculos;
DROP POLICY IF EXISTS "veiculos_insert_tenant" ON public.veiculos;
DROP POLICY IF EXISTS "veiculos_update_tenant" ON public.veiculos;
DROP POLICY IF EXISTS "veiculos_delete_tenant" ON public.veiculos;
DROP POLICY IF EXISTS "atendimentos_select_tenant" ON public.atendimentos;
DROP POLICY IF EXISTS "atendimentos_insert_tenant" ON public.atendimentos;
DROP POLICY IF EXISTS "atendimentos_update_tenant" ON public.atendimentos;
DROP POLICY IF EXISTS "atendimentos_delete_tenant" ON public.atendimentos;

CREATE POLICY "clientes_select_tenant" ON public.clientes
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "clientes_insert_tenant" ON public.clientes
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "clientes_update_tenant" ON public.clientes
  FOR UPDATE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "clientes_delete_tenant" ON public.clientes
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "veiculos_select_tenant" ON public.veiculos
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "veiculos_insert_tenant" ON public.veiculos
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "veiculos_update_tenant" ON public.veiculos
  FOR UPDATE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "veiculos_delete_tenant" ON public.veiculos
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimentos_select_tenant" ON public.atendimentos
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimentos_insert_tenant" ON public.atendimentos
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimentos_update_tenant" ON public.atendimentos
  FOR UPDATE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimentos_delete_tenant" ON public.atendimentos
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );
