-- CRM (LicençaCRM) reads device_tokens via anon key + RPC — no LavaCash user session.
-- Joins empresas for display labels; SECURITY DEFINER bypasses RLS on base tables.

CREATE OR REPLACE FUNCTION public.get_device_tokens_for_crm()
RETURNS TABLE (
  id uuid,
  device_id text,
  empresa_id uuid,
  empresa_nome text,
  fcm_token text,
  platform text,
  updated_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT
    dt.id,
    dt.device_id,
    dt.empresa_id,
    e.nome,
    dt.fcm_token,
    dt.platform,
    dt.updated_at
  FROM public.device_tokens dt
  LEFT JOIN public.empresas e ON e.id = dt.empresa_id
  ORDER BY dt.updated_at DESC;
$$;

COMMENT ON FUNCTION public.get_device_tokens_for_crm() IS
  'LicençaCRM: list FCM rows with empresa name; callable with anon key.';

GRANT EXECUTE ON FUNCTION public.get_device_tokens_for_crm() TO anon;
