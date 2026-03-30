-- LavaCash: single consolidated schema (multi-tenant, RLS).
-- License validation uses a separate Supabase project (Flutter: license_supabase).

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.normalize_search(input TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
  SELECT lower(extensions.unaccent(trim(input)));
$$;

-- ---------------------------------------------------------------------------
-- Tenants: empresas (pre-provisioned with owner_id NULL until claim_empresa)
-- ---------------------------------------------------------------------------
CREATE TABLE public.empresas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  activation_code TEXT NOT NULL UNIQUE,
  nome TEXT NOT NULL,
  telefone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "empresas_select_own" ON public.empresas
  FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "empresas_update_own" ON public.empresas
  FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

CREATE POLICY "empresas_insert_own" ON public.empresas
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE OR REPLACE FUNCTION public.get_empresa_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.empresas WHERE owner_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.claim_empresa(p_activation_code TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id UUID;
BEGIN
  UPDATE public.empresas
  SET
    owner_id = auth.uid(),
    updated_at = now()
  WHERE
    activation_code = p_activation_code
    AND owner_id IS NULL
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.claim_empresa(TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Core tables (tenant-scoped via empresa_id)
-- ---------------------------------------------------------------------------
CREATE TABLE public.clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE
);

CREATE INDEX idx_clientes_empresa ON public.clientes(empresa_id);

CREATE TABLE public.veiculos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  placa TEXT NOT NULL,
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  CONSTRAINT veiculos_placa_empresa_unique UNIQUE (placa, empresa_id)
);

CREATE INDEX idx_veiculos_placa ON public.veiculos(placa);
CREATE INDEX idx_veiculos_cliente ON public.veiculos(cliente_id);
CREATE INDEX idx_veiculos_empresa ON public.veiculos(empresa_id);

CREATE TABLE public.atendimentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE CASCADE,
  hora_entrada TIMESTAMPTZ NOT NULL DEFAULT now(),
  hora_saida TIMESTAMPTZ,
  duracao_minutos INT,
  valor NUMERIC(10,2),
  forma_pagamento TEXT CHECK (forma_pagamento IN ('dinheiro','pix','debito','credito')),
  status TEXT NOT NULL DEFAULT 'em_andamento' CHECK (status IN ('em_andamento','finalizado','cancelado')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  nome_servico TEXT,
  observacao TEXT,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE
);

CREATE INDEX idx_atendimentos_veiculo ON public.atendimentos(veiculo_id);
CREATE INDEX idx_atendimentos_status ON public.atendimentos(status);
CREATE INDEX idx_atendimentos_hora_entrada ON public.atendimentos(hora_entrada);
CREATE INDEX idx_atendimentos_empresa ON public.atendimentos(empresa_id);

-- ---------------------------------------------------------------------------
-- Auto-set empresa_id on INSERT when omitted
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_empresa_id_on_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.empresa_id IS NULL THEN
    NEW.empresa_id := public.get_empresa_id();
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER clientes_set_empresa
  BEFORE INSERT ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

CREATE TRIGGER veiculos_set_empresa
  BEFORE INSERT ON public.veiculos
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

CREATE TRIGGER atendimentos_set_empresa
  BEFORE INSERT ON public.atendimentos
  FOR EACH ROW
  EXECUTE FUNCTION public.set_empresa_id_on_insert();

-- ---------------------------------------------------------------------------
-- RLS (tenant isolation)
-- ---------------------------------------------------------------------------
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.atendimentos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "clientes_empresa" ON public.clientes
  FOR ALL USING (empresa_id = public.get_empresa_id());

CREATE POLICY "veiculos_empresa" ON public.veiculos
  FOR ALL USING (empresa_id = public.get_empresa_id());

CREATE POLICY "atendimentos_empresa" ON public.atendimentos
  FOR ALL USING (empresa_id = public.get_empresa_id());

-- ---------------------------------------------------------------------------
-- Search indexes (normalized)
-- ---------------------------------------------------------------------------
CREATE INDEX idx_clientes_nome_normalized
  ON public.clientes (public.normalize_search(nome))
  WHERE NOT is_deleted;

CREATE INDEX idx_veiculos_placa_normalized
  ON public.veiculos (public.normalize_search(placa))
  WHERE NOT is_deleted;

-- ---------------------------------------------------------------------------
-- Views (inherit caller RLS via security_invoker)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.vw_relatorio_diario
WITH (security_invoker = true) AS
SELECT
  SUM(COUNT(*)) OVER () AS total_carros,
  COALESCE(SUM(SUM(valor)) OVER (), 0) AS total_recebido,
  forma_pagamento,
  COUNT(*) AS total_por_forma,
  (
    SELECT COUNT(*)
    FROM public.atendimentos a2
    WHERE a2.status = 'em_andamento'
      AND (a2.hora_entrada AT TIME ZONE 'UTC')::date
          = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
  ) AS total_em_andamento
FROM public.atendimentos
WHERE status = 'finalizado'
  AND (hora_entrada AT TIME ZONE 'UTC')::date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
GROUP BY forma_pagamento;

CREATE OR REPLACE VIEW public.vw_relatorio_mensal
WITH (security_invoker = true) AS
SELECT
  DATE_TRUNC('month', hora_entrada) AS mes,
  COUNT(*) AS total_atendimentos,
  COALESCE(SUM(valor), 0) AS faturamento
FROM public.atendimentos
WHERE status = 'finalizado'
GROUP BY DATE_TRUNC('month', hora_entrada)
ORDER BY mes DESC;

-- ---------------------------------------------------------------------------
-- Report RPCs (SECURITY INVOKER — RLS on atendimentos applies)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_weekly_report(p_year INT, p_month INT)
RETURNS TABLE (
  semana INT,
  total_atendimentos BIGINT,
  faturamento NUMERIC
)
LANGUAGE sql
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    CASE
      WHEN EXTRACT(
        DAY FROM hora_entrada AT TIME ZONE 'UTC'
      ) BETWEEN 1 AND 7 THEN 1
      WHEN EXTRACT(
        DAY FROM hora_entrada AT TIME ZONE 'UTC'
      ) BETWEEN 8 AND 14 THEN 2
      WHEN EXTRACT(
        DAY FROM hora_entrada AT TIME ZONE 'UTC'
      ) BETWEEN 15 AND 21 THEN 3
      ELSE 4
    END AS semana,
    COUNT(*)::BIGINT AS total_atendimentos,
    COALESCE(SUM(valor), 0) AS faturamento
  FROM public.atendimentos
  WHERE status = 'finalizado'
    AND EXTRACT(YEAR FROM hora_entrada AT TIME ZONE 'UTC') = p_year
    AND EXTRACT(MONTH FROM hora_entrada AT TIME ZONE 'UTC') = p_month
  GROUP BY 1
  ORDER BY 1;
$$;

CREATE OR REPLACE FUNCTION public.get_best_weekday_report(p_year INT, p_month INT)
RETURNS TABLE (
  dia_semana TEXT,
  faturamento NUMERIC
)
LANGUAGE sql
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    CASE EXTRACT(DOW FROM hora_entrada AT TIME ZONE 'UTC')
      WHEN 0 THEN 'Domingo'
      WHEN 1 THEN 'Segunda-feira'
      WHEN 2 THEN 'Terça-feira'
      WHEN 3 THEN 'Quarta-feira'
      WHEN 4 THEN 'Quinta-feira'
      WHEN 5 THEN 'Sexta-feira'
      WHEN 6 THEN 'Sábado'
    END AS dia_semana,
    COALESCE(SUM(valor), 0) AS faturamento
  FROM public.atendimentos
  WHERE status = 'finalizado'
    AND EXTRACT(YEAR FROM hora_entrada AT TIME ZONE 'UTC') = p_year
    AND EXTRACT(MONTH FROM hora_entrada AT TIME ZONE 'UTC') = p_month
  GROUP BY EXTRACT(DOW FROM hora_entrada AT TIME ZONE 'UTC')
  ORDER BY faturamento DESC
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.get_weekly_report(INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_best_weekday_report(INT, INT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Vehicle search RPC (SECURITY INVOKER — RLS on veiculos + clientes)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.search_vehicles_normalized(p_query TEXT)
RETURNS TABLE (
  vehicle_id UUID,
  placa TEXT,
  cliente_id UUID,
  client_id UUID,
  client_nome TEXT,
  client_telefone TEXT
)
LANGUAGE sql
SECURITY INVOKER
STABLE
SET search_path = public
AS $$
  SELECT
    v.id AS vehicle_id,
    v.placa,
    v.cliente_id,
    c.id AS client_id,
    c.nome AS client_nome,
    c.telefone AS client_telefone
  FROM public.veiculos v
  INNER JOIN public.clientes c ON c.id = v.cliente_id
  WHERE
    NOT v.is_deleted
    AND NOT c.is_deleted
    AND trim(p_query) <> ''
    AND (
      public.normalize_search(v.placa)
        LIKE '%' || public.normalize_search(trim(p_query)) || '%'
      OR public.normalize_search(c.nome)
        LIKE '%' || public.normalize_search(trim(p_query)) || '%'
    );
$$;

GRANT EXECUTE ON FUNCTION public.search_vehicles_normalized(TEXT) TO authenticated;
