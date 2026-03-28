-- Pre-generated activation keys and RPC to bind a device to a license on first use.

CREATE TABLE IF NOT EXISTS public.activation_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  nome_lavagem TEXT NOT NULL,
  used_by_device_id TEXT UNIQUE,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activation_keys_key ON public.activation_keys(key);

ALTER TABLE public.activation_keys ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all" ON public.activation_keys;
CREATE POLICY "allow_all" ON public.activation_keys FOR ALL USING (true);

CREATE OR REPLACE FUNCTION public.activate_license(
  p_device_id TEXT,
  p_activation_key TEXT
)
RETURNS TABLE (
  id UUID,
  device_id TEXT,
  nome_lavagem TEXT,
  is_active BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
#variable_conflict use_column
DECLARE
  v_trim_device TEXT := trim(p_device_id);
  v_trim_key TEXT := trim(p_activation_key);
  v_row public.activation_keys%ROWTYPE;
  v_license_id UUID;
BEGIN
  IF v_trim_device IS NULL OR length(v_trim_device) = 0 THEN
    RAISE EXCEPTION 'Invalid device_id';
  END IF;
  IF v_trim_key IS NULL OR length(v_trim_key) = 0 THEN
    RAISE EXCEPTION 'Invalid activation key';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.licencas l
    WHERE l.device_id = v_trim_device AND l.is_active
  ) THEN
    RETURN QUERY
    SELECT l.id, l.device_id, l.nome_lavagem, l.is_active
    FROM public.licencas l
    WHERE l.device_id = v_trim_device AND l.is_active
    LIMIT 1;
    RETURN;
  END IF;

  SELECT * INTO v_row
  FROM public.activation_keys ak
  WHERE ak.key = v_trim_key
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid activation key';
  END IF;

  IF v_row.used_by_device_id IS NOT NULL THEN
    IF v_row.used_by_device_id = v_trim_device THEN
      RETURN QUERY
      SELECT l.id, l.device_id, l.nome_lavagem, l.is_active
      FROM public.licencas l
      WHERE l.device_id = v_trim_device AND l.is_active
      LIMIT 1;
      RETURN;
    END IF;
    RAISE EXCEPTION 'Key already used';
  END IF;

  INSERT INTO public.licencas (device_id, nome_lavagem, is_active)
  VALUES (v_trim_device, v_row.nome_lavagem, true)
  ON CONFLICT (device_id) DO UPDATE SET
    nome_lavagem = EXCLUDED.nome_lavagem,
    is_active = true,
    updated_at = now()
  RETURNING licencas.id INTO v_license_id;

  UPDATE public.activation_keys
  SET used_by_device_id = v_trim_device,
      used_at = now()
  WHERE activation_keys.id = v_row.id;

  RETURN QUERY
  SELECT l.id, l.device_id, l.nome_lavagem, l.is_active
  FROM public.licencas l
  WHERE l.id = v_license_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.activate_license(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.activate_license(TEXT, TEXT) TO authenticated;
