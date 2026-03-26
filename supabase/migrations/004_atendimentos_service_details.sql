-- Optional service line items for in-progress detailing UI.
ALTER TABLE public.atendimentos
  ADD COLUMN IF NOT EXISTS nome_servico TEXT;

ALTER TABLE public.atendimentos
  ADD COLUMN IF NOT EXISTS observacao TEXT;
