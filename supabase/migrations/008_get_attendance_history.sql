-- History of finalized attendances with optional text filter (client name / plate).
-- SECURITY INVOKER: RLS on atendimentos / veiculos / clientes applies.

CREATE OR REPLACE FUNCTION public.get_attendance_history(
  p_start_date DATE,
  p_end_date DATE,
  p_query TEXT DEFAULT ''
)
RETURNS TABLE (
  atendimento_id UUID,
  veiculo_id UUID,
  placa TEXT,
  cliente_nome TEXT,
  hora_entrada_local TIMESTAMP,
  valor NUMERIC,
  forma_pagamento TEXT
)
LANGUAGE sql
SECURITY INVOKER
STABLE
SET search_path = public
AS $$
  SELECT
    a.id AS atendimento_id,
    v.id AS veiculo_id,
    v.placa,
    COALESCE(c.nome, '—') AS cliente_nome,
    (a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
      AS hora_entrada_local,
    a.valor,
    a.forma_pagamento::TEXT AS forma_pagamento
  FROM public.atendimentos a
  INNER JOIN public.veiculos v ON v.id = a.veiculo_id
  INNER JOIN public.clientes c ON c.id = v.cliente_id
  WHERE
    a.status = 'finalizado'
    AND NOT v.is_deleted
    AND NOT c.is_deleted
    AND (
      a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo'
    )::date >= p_start_date
    AND (
      a.hora_entrada AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo'
    )::date <= p_end_date
    AND (
      trim(p_query) = ''
      OR public.normalize_search(v.placa) LIKE '%'
        || public.normalize_search(trim(p_query)) || '%'
      OR public.normalize_search(c.nome) LIKE '%'
        || public.normalize_search(trim(p_query)) || '%'
    )
  ORDER BY a.hora_entrada DESC
  LIMIT 5000;
$$;

GRANT EXECUTE ON FUNCTION public.get_attendance_history(DATE, DATE, TEXT)
  TO authenticated;
