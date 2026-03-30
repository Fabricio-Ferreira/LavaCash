-- LavaCash: single-row app version metadata for in-app update checks (public read).

CREATE TABLE public.app_version (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  latest_version TEXT NOT NULL,
  latest_build_number INT NOT NULL,
  apk_url TEXT NOT NULL,
  is_mandatory BOOLEAN NOT NULL DEFAULT false,
  title TEXT NOT NULL DEFAULT 'Atualizacao disponivel',
  message TEXT NOT NULL DEFAULT '',
  release_notes TEXT[] NOT NULL DEFAULT '{}',
  published_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.app_version ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_version_select_anon" ON public.app_version
  FOR SELECT TO anon USING (true);

CREATE POLICY "app_version_select_authenticated" ON public.app_version
  FOR SELECT TO authenticated USING (true);

GRANT SELECT ON public.app_version TO anon, authenticated;

INSERT INTO public.app_version (
  id,
  latest_version,
  latest_build_number,
  apk_url,
  title,
  message,
  release_notes
)
VALUES (
  1,
  '1.0.0',
  1,
  '',
  'Atualizacao disponivel',
  '',
  '{}'
)
ON CONFLICT (id) DO NOTHING;
