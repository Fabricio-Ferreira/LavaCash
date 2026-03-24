-- Lava Cash MVP schema (apply in Supabase SQL editor or CLI)

CREATE TABLE IF NOT EXISTS public.licencas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT NOT NULL UNIQUE,
  nome_lavagem TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_licencas_device_id ON public.licencas(device_id);

CREATE TABLE IF NOT EXISTS public.clientes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.veiculos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  placa TEXT NOT NULL UNIQUE,
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_deleted BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON public.veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_cliente ON public.veiculos(cliente_id);

CREATE TABLE IF NOT EXISTS public.atendimentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE CASCADE,
  hora_entrada TIMESTAMPTZ NOT NULL DEFAULT now(),
  hora_saida TIMESTAMPTZ,
  duracao_minutos INT,
  valor NUMERIC(10,2),
  forma_pagamento TEXT CHECK (forma_pagamento IN ('dinheiro','pix','debito','credito')),
  status TEXT NOT NULL DEFAULT 'em_andamento' CHECK (status IN ('em_andamento','finalizado','cancelado')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_atendimentos_veiculo ON public.atendimentos(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_atendimentos_status ON public.atendimentos(status);
CREATE INDEX IF NOT EXISTS idx_atendimentos_hora_entrada ON public.atendimentos(hora_entrada);

ALTER TABLE public.licencas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.atendimentos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all" ON public.licencas;
CREATE POLICY "allow_all" ON public.licencas FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all" ON public.clientes;
CREATE POLICY "allow_all" ON public.clientes FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all" ON public.veiculos;
CREATE POLICY "allow_all" ON public.veiculos FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all" ON public.atendimentos;
CREATE POLICY "allow_all" ON public.atendimentos FOR ALL USING (true);

CREATE OR REPLACE VIEW public.vw_relatorio_diario AS
SELECT
  COUNT(*) AS total_carros,
  COALESCE(SUM(valor), 0) AS total_recebido,
  forma_pagamento,
  COUNT(*) AS total_por_forma
FROM public.atendimentos
WHERE status = 'finalizado'
  AND (hora_entrada AT TIME ZONE 'UTC')::date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
GROUP BY forma_pagamento;

CREATE OR REPLACE VIEW public.vw_relatorio_mensal AS
SELECT
  DATE_TRUNC('month', hora_entrada) AS mes,
  COUNT(*) AS total_atendimentos,
  COALESCE(SUM(valor), 0) AS faturamento
FROM public.atendimentos
WHERE status = 'finalizado'
GROUP BY DATE_TRUNC('month', hora_entrada)
ORDER BY mes DESC;
