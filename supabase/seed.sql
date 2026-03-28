-- Lava Cash test data for local `supabase db reset` or SQL Editor on remote.
-- Idempotent: safe to re-run (ON CONFLICT).
-- License/device auth is handled in the separate license Supabase project, not here.

-- Clients
INSERT INTO public.clientes (id, nome, telefone) VALUES
  ('20000000-0000-4000-8000-000000000001'::uuid, 'Maria Santos', '51991110001'),
  ('20000000-0000-4000-8000-000000000002'::uuid, 'João Oliveira', '51992220002'),
  ('20000000-0000-4000-8000-000000000003'::uuid, 'Ana Costa', '51993330003'),
  ('20000000-0000-4000-8000-000000000004'::uuid, 'Pedro Lima', '51994440004'),
  ('20000000-0000-4000-8000-000000000005'::uuid, 'Lucia Ferreira', '51995550005')
ON CONFLICT (id) DO NOTHING;

-- Vehicles (Mercosul + legacy plates)
INSERT INTO public.veiculos (id, placa, cliente_id) VALUES
  ('30000000-0000-4000-8001-000000000001'::uuid, 'ABC1D23',
   '20000000-0000-4000-8000-000000000001'::uuid),
  ('30000000-0000-4000-8001-000000000002'::uuid, 'MNO8P90',
   '20000000-0000-4000-8000-000000000001'::uuid),
  ('30000000-0000-4000-8001-000000000003'::uuid, 'XYZ9K87',
   '20000000-0000-4000-8000-000000000002'::uuid),
  ('30000000-0000-4000-8001-000000000004'::uuid, 'QWE5R42',
   '20000000-0000-4000-8000-000000000003'::uuid),
  ('30000000-0000-4000-8001-000000000005'::uuid, 'RTY2U88',
   '20000000-0000-4000-8000-000000000004'::uuid),
  ('30000000-0000-4000-8001-000000000006'::uuid, 'UIO7I77',
   '20000000-0000-4000-8000-000000000004'::uuid),
  ('30000000-0000-4000-8001-000000000007'::uuid, 'PAS6S33',
   '20000000-0000-4000-8000-000000000005'::uuid),
  ('30000000-0000-4000-8001-000000000008'::uuid, 'DFG4H99',
   '20000000-0000-4000-8000-000000000005'::uuid)
ON CONFLICT (placa) DO NOTHING;

-- 50 finalized services spread over ~29 days (14h steps from now)
INSERT INTO public.atendimentos (
  id,
  veiculo_id,
  hora_entrada,
  hora_saida,
  duracao_minutos,
  valor,
  forma_pagamento,
  status,
  updated_at
)
SELECT
  ('c0010000-0000-4000-8000-' || lpad(to_hex(gs), 12, '0'))::uuid,
  ('30000000-0000-4000-8001-' ||
    lpad(to_hex(1 + ((gs - 1) % 8)), 12, '0'))::uuid,
  now() - ((gs * 14)::text || ' hours')::interval,
  now() - ((gs * 14)::text || ' hours')::interval + interval '45 minutes',
  45,
  round((35 + (gs % 28) * 3 + (gs % 7) * 1.5)::numeric, 2),
  CASE (gs % 4)
    WHEN 0 THEN 'dinheiro'
    WHEN 1 THEN 'pix'
    WHEN 2 THEN 'debito'
    ELSE 'credito'
  END,
  'finalizado',
  now() - ((gs * 14)::text || ' hours')::interval + interval '45 minutes'
FROM generate_series(1, 50) AS gs
ON CONFLICT (id) DO NOTHING;

-- Finalized today (UTC) so vw_relatorio_diario returns rows. That view filters:
--   status = 'finalizado'
--   AND (hora_entrada AT TIME ZONE 'UTC')::date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::date
-- You cannot INSERT into a view; data lives in atendimentos.
INSERT INTO public.atendimentos (
  id,
  veiculo_id,
  hora_entrada,
  hora_saida,
  duracao_minutos,
  valor,
  forma_pagamento,
  status,
  updated_at
) VALUES
  (
    'c0030000-0000-4000-8000-000000000001'::uuid,
    '30000000-0000-4000-8001-000000000001'::uuid,
    ((now() AT TIME ZONE 'utc')::date + interval '8 hours') AT TIME ZONE 'utc',
    ((now() AT TIME ZONE 'utc')::date + interval '8 hours 45 minutes') AT TIME ZONE 'utc',
    45,
    55.00,
    'dinheiro',
    'finalizado',
    ((now() AT TIME ZONE 'utc')::date + interval '8 hours 45 minutes') AT TIME ZONE 'utc'
  ),
  (
    'c0030000-0000-4000-8000-000000000002'::uuid,
    '30000000-0000-4000-8001-000000000002'::uuid,
    ((now() AT TIME ZONE 'utc')::date + interval '10 hours') AT TIME ZONE 'utc',
    ((now() AT TIME ZONE 'utc')::date + interval '10 hours 45 minutes') AT TIME ZONE 'utc',
    45,
    62.50,
    'pix',
    'finalizado',
    ((now() AT TIME ZONE 'utc')::date + interval '10 hours 45 minutes') AT TIME ZONE 'utc'
  ),
  (
    'c0030000-0000-4000-8000-000000000003'::uuid,
    '30000000-0000-4000-8001-000000000003'::uuid,
    ((now() AT TIME ZONE 'utc')::date + interval '12 hours') AT TIME ZONE 'utc',
    ((now() AT TIME ZONE 'utc')::date + interval '12 hours 45 minutes') AT TIME ZONE 'utc',
    45,
    48.00,
    'debito',
    'finalizado',
    ((now() AT TIME ZONE 'utc')::date + interval '12 hours 45 minutes') AT TIME ZONE 'utc'
  ),
  (
    'c0030000-0000-4000-8000-000000000004'::uuid,
    '30000000-0000-4000-8001-000000000004'::uuid,
    ((now() AT TIME ZONE 'utc')::date + interval '14 hours') AT TIME ZONE 'utc',
    ((now() AT TIME ZONE 'utc')::date + interval '14 hours 45 minutes') AT TIME ZONE 'utc',
    45,
    72.00,
    'credito',
    'finalizado',
    ((now() AT TIME ZONE 'utc')::date + interval '14 hours 45 minutes') AT TIME ZONE 'utc'
  )
ON CONFLICT (id) DO NOTHING;

-- 3 in progress today (dashboard / emAndamento)
INSERT INTO public.atendimentos (
  id,
  veiculo_id,
  hora_entrada,
  hora_saida,
  duracao_minutos,
  valor,
  forma_pagamento,
  status,
  updated_at
) VALUES
  (
    'c0020000-0000-4000-8000-000000000001'::uuid,
    '30000000-0000-4000-8001-000000000001'::uuid,
    now() - interval '20 minutes',
    NULL,
    NULL,
    NULL,
    NULL,
    'em_andamento',
    now() - interval '20 minutes'
  ),
  (
    'c0020000-0000-4000-8000-000000000002'::uuid,
    '30000000-0000-4000-8001-000000000003'::uuid,
    now() - interval '50 minutes',
    NULL,
    NULL,
    NULL,
    NULL,
    'em_andamento',
    now() - interval '50 minutes'
  ),
  (
    'c0020000-0000-4000-8000-000000000003'::uuid,
    '30000000-0000-4000-8001-000000000005'::uuid,
    now() - interval '2 hours',
    NULL,
    NULL,
    NULL,
    NULL,
    'em_andamento',
    now() - interval '2 hours'
  )
ON CONFLICT (id) DO NOTHING;

-- Migration 003: get_weekly_report + get_best_weekday_report (p_year / p_month in UTC).
-- Buckets: days 1-7, 8-14, 15-21, 22+; best weekday = Friday (3 high-value rows).
INSERT INTO public.atendimentos (
  id,
  veiculo_id,
  hora_entrada,
  hora_saida,
  duracao_minutos,
  valor,
  forma_pagamento,
  status,
  updated_at
)
WITH m AS (
  SELECT date_trunc('month', (CURRENT_TIMESTAMP AT TIME ZONE 'utc')) AS ms
),
fri AS (
  SELECT (
    (m.ms::date + (
      (5 - EXTRACT(DOW FROM m.ms::date)::int + 7) % 7
    ) * interval '1 day')
    + interval '0 hours'
  )::date AS d
  FROM m
)
SELECT
  spec.id,
  spec.veiculo_id,
  spec.entrada,
  spec.entrada + interval '40 minutes',
  40,
  spec.valor,
  spec.forma,
  'finalizado',
  spec.entrada + interval '40 minutes'
FROM (
  SELECT
    'c0040000-0000-4000-8000-000000000001'::uuid AS id,
    '30000000-0000-4000-8001-000000000001'::uuid AS veiculo_id,
    (m.ms + interval '1 day' + interval '10 hours') AT TIME ZONE 'utc' AS entrada,
    42::numeric AS valor,
    'dinheiro'::text AS forma
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000002'::uuid,
    '30000000-0000-4000-8001-000000000002'::uuid,
    (m.ms + interval '9 days' + interval '11 hours') AT TIME ZONE 'utc',
    55,
    'pix'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000003'::uuid,
    '30000000-0000-4000-8001-000000000003'::uuid,
    (m.ms + interval '16 days' + interval '9 hours') AT TIME ZONE 'utc',
    48,
    'debito'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000004'::uuid,
    '30000000-0000-4000-8001-000000000004'::uuid,
    (m.ms + interval '23 days' + interval '13 hours') AT TIME ZONE 'utc',
    61,
    'credito'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000005'::uuid,
    '30000000-0000-4000-8001-000000000005'::uuid,
    (fri.d + time '09:30') AT TIME ZONE 'utc',
    185,
    'pix'
  FROM fri
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000006'::uuid,
    '30000000-0000-4000-8001-000000000006'::uuid,
    (fri.d + time '11:00') AT TIME ZONE 'utc',
    195,
    'credito'
  FROM fri
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000007'::uuid,
    '30000000-0000-4000-8001-000000000007'::uuid,
    (fri.d + time '15:45') AT TIME ZONE 'utc',
    210,
    'dinheiro'
  FROM fri
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000008'::uuid,
    '30000000-0000-4000-8001-000000000008'::uuid,
    (m.ms + interval '4 days' + interval '14 hours') AT TIME ZONE 'utc',
    38,
    'debito'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-000000000009'::uuid,
    '30000000-0000-4000-8001-000000000001'::uuid,
    (m.ms + interval '11 days' + interval '10 hours') AT TIME ZONE 'utc',
    44,
    'pix'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-00000000000a'::uuid,
    '30000000-0000-4000-8001-000000000002'::uuid,
    (m.ms + interval '18 days' + interval '16 hours') AT TIME ZONE 'utc',
    52,
    'dinheiro'
  FROM m
  UNION ALL
  SELECT
    'c0040000-0000-4000-8000-00000000000b'::uuid,
    '30000000-0000-4000-8001-000000000003'::uuid,
    (m.ms + interval '27 days' + interval '12 hours') AT TIME ZONE 'utc',
    58,
    'credito'
  FROM m
) AS spec
ON CONFLICT (id) DO NOTHING;

-- 1 cancelled yesterday (excluded from reports)
INSERT INTO public.atendimentos (
  id,
  veiculo_id,
  hora_entrada,
  hora_saida,
  duracao_minutos,
  valor,
  forma_pagamento,
  status,
  updated_at
) VALUES
  (
    'c0020000-0000-4000-8000-000000000004'::uuid,
    '30000000-0000-4000-8001-000000000008'::uuid,
    (
      ((now() AT TIME ZONE 'utc')::date - interval '1 day' + interval '15 hours')
      AT TIME ZONE 'utc'
    ),
    NULL,
    NULL,
    NULL,
    NULL,
    'cancelado',
    (
      ((now() AT TIME ZONE 'utc')::date - interval '1 day' + interval '15 hours')
      AT TIME ZONE 'utc'
    )
  )
ON CONFLICT (id) DO NOTHING;
