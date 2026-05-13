-- INSERT on servicos_catalogo failed with RLS for some sessions:
-- 1) WITH CHECK (empresa_id IN (...)) treats NULL IN (...) as not allowed when
--    empresa_id is still null in an edge evaluation path.
-- 2) BEFORE INSERT triggers fire in name order: "mais_utilizado" ran before
--    set_empresa, so limits used NULL empresa_id.
-- Allow NULL empresa_id only on INSERT (trigger always fills it). Force trigger
-- order with alphabetical names.

DROP POLICY IF EXISTS "servicos_catalogo_insert_tenant" ON public.servicos_catalogo;

CREATE POLICY "servicos_catalogo_insert_tenant" ON public.servicos_catalogo
  FOR INSERT
  WITH CHECK (
    empresa_id IS NULL
    OR empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = auth.uid()
    )
  );

DROP TRIGGER IF EXISTS servicos_catalogo_set_empresa ON public.servicos_catalogo;
DROP TRIGGER IF EXISTS servicos_catalogo_mais_utilizado_limit
  ON public.servicos_catalogo;

CREATE TRIGGER servicos_catalogo_a_set_empresa
  BEFORE INSERT ON public.servicos_catalogo
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

CREATE TRIGGER servicos_catalogo_b_mais_utilizado_limit
  BEFORE INSERT OR UPDATE OF is_mais_utilizado, is_deleted
  ON public.servicos_catalogo
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_servicos_catalogo_mais_utilizado_limit();
