-- =========================================================================
-- 004_multiuser_roles_fcm.sql
-- Adds multi-user support per empresa with role-based access (admin/operador)
-- and device_tokens table for Firebase Cloud Messaging.
--
-- SAFE TO RUN on existing data:
--   Step 1 — create empresa_usuarios table
--   Step 2 — migrate existing owners as admins (preserves all existing data)
--   Step 3 — update get_empresa_id() to use empresa_usuarios
--   Step 4 — add empresa_convites table (operador invite flow)
--   Step 5 — add device_tokens table (FCM)
-- =========================================================================

-- ---------------------------------------------------------------------------
-- Step 1: empresa_usuarios
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.empresa_usuarios (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id  UUID        NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role        TEXT        NOT NULL CHECK (role IN ('admin', 'operador')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(empresa_id, user_id)
);

ALTER TABLE public.empresa_usuarios ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- Step 2: Migrate existing owners → admin rows (idempotent via ON CONFLICT DO NOTHING)
-- ---------------------------------------------------------------------------
INSERT INTO public.empresa_usuarios (empresa_id, user_id, role)
SELECT id, owner_id, 'admin'
FROM   public.empresas
WHERE  owner_id IS NOT NULL
ON CONFLICT (empresa_id, user_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Step 3: Update get_empresa_id() to check empresa_usuarios FIRST
--   (SECURITY DEFINER bypasses RLS on empresa_usuarios internally — no recursion)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_empresa_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT empresa_id
  FROM   public.empresa_usuarios
  WHERE  user_id = auth.uid()
  LIMIT  1
$$;

-- RLS: members can see all users in their empresa
CREATE POLICY "empresa_usuarios_select" ON public.empresa_usuarios
  FOR SELECT USING (empresa_id = public.get_empresa_id());

-- Only admins can insert/update/delete members
CREATE POLICY "empresa_usuarios_admin_write" ON public.empresa_usuarios
  FOR ALL USING (
    empresa_id = public.get_empresa_id()
    AND EXISTS (
      SELECT 1
      FROM   public.empresa_usuarios eu
      WHERE  eu.user_id    = auth.uid()
        AND  eu.empresa_id = public.get_empresa_id()
        AND  eu.role       = 'admin'
    )
  );

-- RPC: get current user's role in their empresa
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role
  FROM   public.empresa_usuarios
  WHERE  user_id = auth.uid()
  LIMIT  1
$$;

GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;

-- RPC: insert user as admin after claim/create (called by claim_empresa trigger or app)
CREATE OR REPLACE FUNCTION public.register_user_in_empresa(
  p_empresa_id UUID,
  p_role       TEXT DEFAULT 'admin'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.empresa_usuarios (empresa_id, user_id, role)
  VALUES (p_empresa_id, auth.uid(), p_role)
  ON CONFLICT (empresa_id, user_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user_in_empresa(UUID, TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Step 4: empresa_convites — admin pre-registers operador activation codes
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.empresa_convites (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id      UUID        NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  activation_code TEXT        NOT NULL,
  role            TEXT        NOT NULL DEFAULT 'operador' CHECK (role IN ('admin', 'operador')),
  claimed_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(empresa_id, activation_code)
);

ALTER TABLE public.empresa_convites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "convites_admin_all" ON public.empresa_convites
  FOR ALL USING (
    empresa_id = public.get_empresa_id()
    AND EXISTS (
      SELECT 1
      FROM   public.empresa_usuarios eu
      WHERE  eu.user_id    = auth.uid()
        AND  eu.empresa_id = public.get_empresa_id()
        AND  eu.role       = 'admin'
    )
  );

-- RPC: operador device calls this after auth to link itself to an empresa via convite
CREATE OR REPLACE FUNCTION public.accept_empresa_convite(p_activation_code TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_empresa_id  UUID;
  v_role        TEXT;
BEGIN
  SELECT empresa_id, role
  INTO   v_empresa_id, v_role
  FROM   public.empresa_convites
  WHERE  activation_code = p_activation_code
    AND  claimed_at      IS NULL;

  IF v_empresa_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO public.empresa_usuarios (empresa_id, user_id, role)
  VALUES (v_empresa_id, auth.uid(), v_role)
  ON CONFLICT (empresa_id, user_id) DO NOTHING;

  UPDATE public.empresa_convites
  SET    claimed_at = now()
  WHERE  activation_code = p_activation_code;

  RETURN v_empresa_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_empresa_convite(TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Step 5: device_tokens — FCM tokens per device (for push notifications)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.device_tokens (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id  UUID        REFERENCES public.empresas(id) ON DELETE CASCADE,
  device_id   TEXT        NOT NULL,
  fcm_token   TEXT        NOT NULL,
  platform    TEXT        NOT NULL DEFAULT 'android',
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(device_id)
);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "device_tokens_own" ON public.device_tokens
  FOR ALL USING (user_id = auth.uid());

-- RPC: upsert FCM token for the current device
CREATE OR REPLACE FUNCTION public.upsert_device_token(
  p_device_id TEXT,
  p_fcm_token TEXT,
  p_platform  TEXT DEFAULT 'android'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.device_tokens (user_id, empresa_id, device_id, fcm_token, platform, updated_at)
  VALUES (
    auth.uid(),
    public.get_empresa_id(),
    p_device_id,
    p_fcm_token,
    p_platform,
    now()
  )
  ON CONFLICT (device_id) DO UPDATE
    SET fcm_token  = EXCLUDED.fcm_token,
        updated_at = now(),
        user_id    = auth.uid(),
        empresa_id = public.get_empresa_id();
END;
$$;

GRANT EXECUTE ON FUNCTION public.upsert_device_token(TEXT, TEXT, TEXT) TO authenticated;
