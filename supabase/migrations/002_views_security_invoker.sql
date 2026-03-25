-- Enforce RLS/permissions of the querying user (not the view owner).
-- Fixes Supabase linter: views must not behave as SECURITY DEFINER.

ALTER VIEW public.vw_relatorio_diario SET (security_invoker = true);
ALTER VIEW public.vw_relatorio_mensal SET (security_invoker = true);
