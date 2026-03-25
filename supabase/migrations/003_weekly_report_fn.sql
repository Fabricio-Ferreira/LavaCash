-- Weekly blocks + best weekday of month (RPC for monthly report UI).

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

GRANT EXECUTE ON FUNCTION public.get_weekly_report(INT, INT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_weekly_report(INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_best_weekday_report(INT, INT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_best_weekday_report(INT, INT) TO authenticated;
