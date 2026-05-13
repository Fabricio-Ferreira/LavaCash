-- PostgREST: insert(...).select() needs BOTH INSERT WITH CHECK and SELECT visibility
-- on the returned row. Ensure authenticated can use the table and policies are
-- stable (EXISTS + (SELECT auth.uid())).

GRANT SELECT, INSERT, UPDATE, DELETE ON public.servicos_catalogo TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.atendimento_servicos TO authenticated;

DROP POLICY IF EXISTS "servicos_catalogo_select_tenant" ON public.servicos_catalogo;
DROP POLICY IF EXISTS "servicos_catalogo_insert_tenant" ON public.servicos_catalogo;
DROP POLICY IF EXISTS "servicos_catalogo_update_tenant" ON public.servicos_catalogo;
DROP POLICY IF EXISTS "servicos_catalogo_delete_tenant" ON public.servicos_catalogo;

CREATE POLICY "servicos_catalogo_select_tenant" ON public.servicos_catalogo
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM public.empresas e
      WHERE e.id = servicos_catalogo.empresa_id
        AND e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_insert_tenant" ON public.servicos_catalogo
  FOR INSERT WITH CHECK (
    empresa_id IS NULL
    OR EXISTS (
      SELECT 1
      FROM public.empresas e
      WHERE e.id = empresa_id
        AND e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_update_tenant" ON public.servicos_catalogo
  FOR UPDATE USING (
    EXISTS (
      SELECT 1
      FROM public.empresas e
      WHERE e.id = servicos_catalogo.empresa_id
        AND e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.empresas e
      WHERE e.id = servicos_catalogo.empresa_id
        AND e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_delete_tenant" ON public.servicos_catalogo
  FOR DELETE USING (
    EXISTS (
      SELECT 1
      FROM public.empresas e
      WHERE e.id = servicos_catalogo.empresa_id
        AND e.owner_id = (SELECT auth.uid())
    )
  );
