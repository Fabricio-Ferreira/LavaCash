-- Service catalog per tenant, line items per attendance, valor sync, reports RPC.

-- ---------------------------------------------------------------------------
-- catalog
-- ---------------------------------------------------------------------------
CREATE TABLE public.servicos_catalogo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  valor_padrao NUMERIC(10,2) NOT NULL DEFAULT 0,
  observacao TEXT,
  is_mais_utilizado BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_servicos_catalogo_empresa
  ON public.servicos_catalogo(empresa_id)
  WHERE NOT is_deleted;

CREATE INDEX idx_servicos_catalogo_mais_utilizado
  ON public.servicos_catalogo(empresa_id)
  WHERE is_mais_utilizado AND NOT is_deleted;

CREATE TRIGGER servicos_catalogo_set_empresa
  BEFORE INSERT ON public.servicos_catalogo
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

-- ---------------------------------------------------------------------------
-- line items
-- ---------------------------------------------------------------------------
CREATE TABLE public.atendimento_servicos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  atendimento_id UUID NOT NULL REFERENCES public.atendimentos(id) ON DELETE CASCADE,
  servico_catalogo_id UUID REFERENCES public.servicos_catalogo(id) ON DELETE SET NULL,
  nome TEXT NOT NULL,
  valor NUMERIC(10,2) NOT NULL,
  observacao TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_atendimento_servicos_atendimento
  ON public.atendimento_servicos(atendimento_id);

CREATE INDEX idx_atendimento_servicos_empresa
  ON public.atendimento_servicos(empresa_id);

-- Denormalize empresa_id from parent attendance.
CREATE OR REPLACE FUNCTION public.set_atendimento_servico_empresa()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  SELECT a.empresa_id INTO NEW.empresa_id
  FROM public.atendimentos a
  WHERE a.id = NEW.atendimento_id;
  IF NEW.empresa_id IS NULL THEN
    RAISE EXCEPTION 'atendimento not found';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER atendimento_servicos_set_empresa
  BEFORE INSERT OR UPDATE OF atendimento_id
  ON public.atendimento_servicos
  FOR EACH ROW
  EXECUTE FUNCTION public.set_atendimento_servico_empresa();

-- Recalculate atendimentos.valor only while line items exist (legacy rows
-- without lines keep atendimentos.valor as set by the app).
CREATE OR REPLACE FUNCTION public.recalc_atendimento_valor_from_lines()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  aid uuid;
  v_sum numeric(10,2);
BEGIN
  IF TG_OP = 'DELETE' THEN
    aid := OLD.atendimento_id;
  ELSE
    aid := NEW.atendimento_id;
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.atendimento_servicos s WHERE s.atendimento_id = aid
  ) THEN
    SELECT COALESCE(SUM(s.valor), 0)::numeric(10,2) INTO v_sum
    FROM public.atendimento_servicos s
    WHERE s.atendimento_id = aid;
    UPDATE public.atendimentos
    SET valor = v_sum,
        updated_at = now()
    WHERE id = aid;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER atendimento_servicos_recalc_valor
  AFTER INSERT OR UPDATE OR DELETE
  ON public.atendimento_servicos
  FOR EACH ROW
  EXECUTE FUNCTION public.recalc_atendimento_valor_from_lines();

-- At most 3 "mais utilizado" per empresa (non-deleted).
CREATE OR REPLACE FUNCTION public.enforce_servicos_catalogo_mais_utilizado_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cnt int;
BEGIN
  IF NEW.is_mais_utilizado IS NOT TRUE THEN
    RETURN NEW;
  END IF;
  SELECT COUNT(*) INTO cnt
  FROM public.servicos_catalogo c
  WHERE c.empresa_id = NEW.empresa_id
    AND NOT c.is_deleted
    AND c.is_mais_utilizado
    AND c.id IS DISTINCT FROM NEW.id;
  IF cnt >= 3 THEN
    RAISE EXCEPTION
      'Máximo de 3 serviços marcados como mais utilizados.';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER servicos_catalogo_mais_utilizado_limit
  BEFORE INSERT OR UPDATE OF is_mais_utilizado, is_deleted
  ON public.servicos_catalogo
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_servicos_catalogo_mais_utilizado_limit();

-- ---------------------------------------------------------------------------
-- RLS (tenant)
-- ---------------------------------------------------------------------------
ALTER TABLE public.servicos_catalogo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.atendimento_servicos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "servicos_catalogo_select_tenant" ON public.servicos_catalogo
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_insert_tenant" ON public.servicos_catalogo
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_update_tenant" ON public.servicos_catalogo
  FOR UPDATE USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "servicos_catalogo_delete_tenant" ON public.servicos_catalogo
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimento_servicos_select_tenant" ON public.atendimento_servicos
  FOR SELECT USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimento_servicos_insert_tenant" ON public.atendimento_servicos
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimento_servicos_update_tenant" ON public.atendimento_servicos
  FOR UPDATE USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "atendimento_servicos_delete_tenant" ON public.atendimento_servicos
  FOR DELETE USING (
    empresa_id IN (
      SELECT e.id FROM public.empresas e WHERE e.owner_id = (SELECT auth.uid())
    )
  );

-- ---------------------------------------------------------------------------
-- Reports: revenue / count per service name (lines + legacy without lines)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_service_breakdown_report(
  p_start date,
  p_end date
)
RETURNS TABLE (
  nome_exibicao text,
  quantidade bigint,
  faturamento numeric
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  WITH line_rows AS (
    SELECT
      TRIM(BOTH FROM s.nome) AS raw_nome,
      s.valor,
      (a.hora_saida AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date
        AS data_ref
    FROM public.atendimento_servicos s
    INNER JOIN public.atendimentos a ON a.id = s.atendimento_id
    WHERE a.status = 'finalizado'
      AND a.hora_saida IS NOT NULL
      AND (a.hora_saida AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date
        BETWEEN p_start AND p_end
  ),
  legacy_rows AS (
    SELECT
      TRIM(BOTH FROM a.nome_servico) AS raw_nome,
      a.valor,
      (a.hora_saida AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date
        AS data_ref
    FROM public.atendimentos a
    WHERE a.status = 'finalizado'
      AND a.hora_saida IS NOT NULL
      AND (a.hora_saida AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date
        BETWEEN p_start AND p_end
      AND NOT EXISTS (
        SELECT 1 FROM public.atendimento_servicos s WHERE s.atendimento_id = a.id
      )
      AND a.nome_servico IS NOT NULL
      AND TRIM(BOTH FROM a.nome_servico) <> ''
      AND a.valor IS NOT NULL
  ),
  unioned AS (
    SELECT * FROM line_rows
    UNION ALL
    SELECT * FROM legacy_rows
  )
  SELECT
    u.raw_nome AS nome_exibicao,
    COUNT(*)::bigint AS quantidade,
    COALESCE(SUM(u.valor), 0)::numeric AS faturamento
  FROM unioned u
  GROUP BY u.raw_nome
  ORDER BY faturamento DESC, nome_exibicao ASC;
$$;

GRANT EXECUTE ON FUNCTION public.get_service_breakdown_report(DATE, DATE)
  TO authenticated;
