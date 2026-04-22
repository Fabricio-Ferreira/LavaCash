-- Paginate by distinct vehicle (10 per page by default). total_veiculos repeats
-- on each row for client convenience. p_fetch_all_vehicles skips paging and keeps
-- a 5000-row cap for PDF / full export.

DROP FUNCTION IF EXISTS public.get_attendance_history(DATE, DATE, TEXT);

CREATE OR REPLACE FUNCTION public.get_attendance_history(
  p_start_date DATE,
  p_end_date DATE,
  p_query TEXT DEFAULT '',
  p_vehicle_limit INT DEFAULT 10,
  p_vehicle_offset INT DEFAULT 0,
  p_fetch_all_vehicles BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
  atendimento_id UUID,
  veiculo_id UUID,
  placa TEXT,
  cliente_nome TEXT,
  hora_entrada_local TIMESTAMP,
  valor NUMERIC,
  forma_pagamento TEXT,
  total_veiculos INT
)
LANGUAGE sql
SECURITY INVOKER
STABLE
SET search_path = public
AS $$
  WITH filtered AS (
    SELECT
      a.id AS atendimento_id,
      v.id AS veiculo_id,
      v.placa,
      COALESCE(c.nome, '—') AS cliente_nome,
      (a.hora_entrada AT TIME ZONE 'America/Sao_Paulo') AS hora_entrada_local,
      a.valor,
      a.forma_pagamento::TEXT AS forma_pagamento,
      a.hora_entrada
    FROM public.atendimentos a
    INNER JOIN public.veiculos v ON v.id = a.veiculo_id
    INNER JOIN public.clientes c ON c.id = v.cliente_id
    WHERE
      a.status = 'finalizado'
      AND NOT v.is_deleted
      AND NOT c.is_deleted
      AND (a.hora_entrada AT TIME ZONE 'America/Sao_Paulo')::date >= p_start_date
      AND (a.hora_entrada AT TIME ZONE 'America/Sao_Paulo')::date <= p_end_date
      AND (
        trim(p_query) = ''
        OR public.normalize_search(v.placa) LIKE '%'
          || public.normalize_search(trim(p_query)) || '%'
        OR public.normalize_search(c.nome) LIKE '%'
          || public.normalize_search(trim(p_query)) || '%'
      )
  ),
  vehicle_last AS (
    SELECT
      f.veiculo_id,
      MAX(f.hora_entrada) AS last_ts
    FROM filtered f
    GROUP BY f.veiculo_id
  ),
  total_ct AS (
    SELECT COUNT(*)::INT AS n FROM vehicle_last
  ),
  vehicle_page AS (
    SELECT vl.veiculo_id
    FROM vehicle_last vl
    ORDER BY vl.last_ts DESC
    LIMIT CASE
      WHEN p_fetch_all_vehicles THEN 2147483647
      ELSE GREATEST(p_vehicle_limit, 0)
    END
    OFFSET CASE
      WHEN p_fetch_all_vehicles THEN 0
      ELSE GREATEST(p_vehicle_offset, 0)
    END
  )
  SELECT
    f.atendimento_id,
    f.veiculo_id,
    f.placa,
    f.cliente_nome,
    f.hora_entrada_local,
    f.valor,
    f.forma_pagamento,
    tc.n AS total_veiculos
  FROM filtered f
  INNER JOIN vehicle_page vp ON vp.veiculo_id = f.veiculo_id
  CROSS JOIN total_ct tc
  ORDER BY f.hora_entrada DESC
  LIMIT CASE WHEN p_fetch_all_vehicles THEN 5000 ELSE 200000 END;
$$;

GRANT EXECUTE ON FUNCTION public.get_attendance_history(
  DATE,
  DATE,
  TEXT,
  INT,
  INT,
  BOOLEAN
) TO authenticated;
