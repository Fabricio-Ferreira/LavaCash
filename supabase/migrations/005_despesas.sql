-- Expenses (tenant-scoped): daily cash-out for real profit tracking.

CREATE TABLE public.despesas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  categoria TEXT NOT NULL DEFAULT 'outros',
  valor NUMERIC(10, 2) NOT NULL CHECK (valor > 0),
  data_referencia DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_despesas_empresa_data
  ON public.despesas (empresa_id, data_referencia DESC);

CREATE TRIGGER despesas_set_empresa
  BEFORE INSERT ON public.despesas
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

ALTER TABLE public.despesas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "despesas_select_tenant" ON public.despesas
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "despesas_insert_tenant" ON public.despesas
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "despesas_update_tenant" ON public.despesas
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

CREATE POLICY "despesas_delete_tenant" ON public.despesas
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id
      FROM public.empresas e
      WHERE e.owner_id = (SELECT auth.uid())
    )
  );
