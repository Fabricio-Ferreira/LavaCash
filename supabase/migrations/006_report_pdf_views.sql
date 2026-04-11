-- PDF / consolidated report views (atendimentos.valor, public.despesas).
-- Uses security_invoker so RLS on underlying tables applies.

-- ---------------------------------------------------------------------------
-- Daily consolidated row per empresa + calendar day (America/Sao_Paulo).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.vw_relatorio_diario_pdf
WITH (security_invoker = true) AS
WITH entradas AS (
  SELECT
    a.empresa_id,
    (a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date AS data_ref,
    COUNT(*) FILTER (WHERE a.status = 'finalizado') AS total_lavagens,
    COALESCE(SUM(a.valor) FILTER (WHERE a.status = 'finalizado'), 0) AS total_entradas,
    COALESCE(
      AVG(a.valor) FILTER (WHERE a.status = 'finalizado'),
      0
    ) AS ticket_medio,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'dinheiro'
      ),
      0
    ) AS total_dinheiro,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'pix'
      ),
      0
    ) AS total_pix,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'debito'
      ),
      0
    ) AS total_debito,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'credito'
      ),
      0
    ) AS total_credito,
    0::numeric AS total_link
  FROM public.atendimentos a
  GROUP BY 1, 2
),
saidas AS (
  SELECT
    d.empresa_id,
    d.data_referencia AS data_ref,
    COALESCE(SUM(d.valor), 0) AS total_saidas
  FROM public.despesas d
  GROUP BY 1, 2
)
SELECT
  COALESCE(e.empresa_id, s.empresa_id) AS empresa_id,
  COALESCE(e.data_ref, s.data_ref) AS data_ref,
  COALESCE(e.total_lavagens, 0) AS total_lavagens,
  COALESCE(e.total_entradas, 0) AS total_entradas,
  COALESCE(e.ticket_medio, 0) AS ticket_medio,
  COALESCE(e.total_dinheiro, 0) AS total_dinheiro,
  COALESCE(e.total_pix, 0) AS total_pix,
  COALESCE(e.total_debito, 0) AS total_debito,
  COALESCE(e.total_credito, 0) AS total_credito,
  COALESCE(e.total_link, 0) AS total_link,
  COALESCE(s.total_saidas, 0) AS total_saidas,
  COALESCE(e.total_entradas, 0) - COALESCE(s.total_saidas, 0) AS saldo_liquido
FROM entradas e
FULL OUTER JOIN saidas s
  ON e.empresa_id = s.empresa_id
 AND e.data_ref = s.data_ref;

-- ---------------------------------------------------------------------------
-- Monthly consolidated row per empresa + YYYY-MM (America/Sao_Paulo month).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.vw_relatorio_mensal_pdf
WITH (security_invoker = true) AS
WITH entradas AS (
  SELECT
    a.empresa_id,
    to_char(
      date_trunc(
        'month',
        (a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
      ),
      'YYYY-MM'
    ) AS mes_ref,
    COUNT(*) FILTER (WHERE a.status = 'finalizado') AS total_lavagens,
    COALESCE(SUM(a.valor) FILTER (WHERE a.status = 'finalizado'), 0) AS total_entradas,
    COALESCE(
      AVG(a.valor) FILTER (WHERE a.status = 'finalizado'),
      0
    ) AS ticket_medio,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'dinheiro'
      ),
      0
    ) AS total_dinheiro,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'pix'
      ),
      0
    ) AS total_pix,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'debito'
      ),
      0
    ) AS total_debito,
    COALESCE(
      SUM(a.valor) FILTER (
        WHERE a.status = 'finalizado' AND a.forma_pagamento = 'credito'
      ),
      0
    ) AS total_credito,
    0::numeric AS total_link
  FROM public.atendimentos a
  GROUP BY 1, 2
),
saidas AS (
  SELECT
    d.empresa_id,
    to_char(
      date_trunc('month', d.data_referencia::timestamp),
      'YYYY-MM'
    ) AS mes_ref,
    COALESCE(SUM(d.valor), 0) AS total_saidas
  FROM public.despesas d
  GROUP BY 1, 2
)
SELECT
  COALESCE(e.empresa_id, s.empresa_id) AS empresa_id,
  COALESCE(e.mes_ref, s.mes_ref) AS mes_ref,
  COALESCE(e.total_lavagens, 0) AS total_lavagens,
  COALESCE(e.total_entradas, 0) AS total_entradas,
  COALESCE(e.ticket_medio, 0) AS ticket_medio,
  COALESCE(e.total_dinheiro, 0) AS total_dinheiro,
  COALESCE(e.total_pix, 0) AS total_pix,
  COALESCE(e.total_debito, 0) AS total_debito,
  COALESCE(e.total_credito, 0) AS total_credito,
  COALESCE(e.total_link, 0) AS total_link,
  COALESCE(s.total_saidas, 0) AS total_saidas,
  COALESCE(e.total_entradas, 0) - COALESCE(s.total_saidas, 0) AS saldo_liquido
FROM entradas e
FULL OUTER JOIN saidas s
  ON e.empresa_id = s.empresa_id
 AND e.mes_ref = s.mes_ref;

-- ---------------------------------------------------------------------------
-- Attendance lines for PDF (join clientes via veiculos).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.vw_relatorio_diario_atendimentos_detalhe
WITH (security_invoker = true) AS
SELECT
  a.id AS atendimento_id,
  a.empresa_id,
  (a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::date AS data_ref,
  COALESCE(c.nome, '—') AS cliente_nome,
  v.placa,
  (a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') AS hora_entrada_local,
  (a.hora_saida AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') AS hora_saida_local,
  a.valor AS valor_total,
  a.forma_pagamento,
  a.status
FROM public.atendimentos a
INNER JOIN public.veiculos v ON v.id = a.veiculo_id
LEFT JOIN public.clientes c ON c.id = v.cliente_id;

-- ---------------------------------------------------------------------------
-- Expense lines for PDF (despesas).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.vw_relatorio_diario_despesas_detalhe
WITH (security_invoker = true) AS
SELECT
  d.id AS despesa_id,
  d.empresa_id,
  d.data_referencia AS data_ref,
  d.descricao,
  d.categoria,
  d.valor,
  d.created_at AS registrado_em
FROM public.despesas d;
