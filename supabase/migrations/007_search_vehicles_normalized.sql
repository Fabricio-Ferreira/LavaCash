-- Case- and accent-insensitive search (e.g. "JOAO" matches "João").

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.normalize_search(input TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
  SELECT lower(extensions.unaccent(trim(input)));
$$;

CREATE INDEX IF NOT EXISTS idx_clientes_nome_normalized
  ON public.clientes (public.normalize_search(nome))
  WHERE NOT is_deleted;

CREATE INDEX IF NOT EXISTS idx_veiculos_placa_normalized
  ON public.veiculos (public.normalize_search(placa))
  WHERE NOT is_deleted;

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

GRANT EXECUTE ON FUNCTION public.search_vehicles_normalized(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.search_vehicles_normalized(TEXT) TO authenticated;
