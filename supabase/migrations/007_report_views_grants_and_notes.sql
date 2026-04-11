-- Report PDF/detail views: tenant isolation does NOT rely on RPCs.
-- Views use security_invoker (see 006_report_pdf_views.sql) so SELECT runs as
-- the authenticated user and RLS on public.atendimentos / public.despesas
-- applies (same rules as querying those tables directly from the app).
--
-- Direct queries from Flutter (PostgREST) with the user JWT are therefore
-- safe: each empresa_id row is visible only if empresa_id belongs to an
-- empresa owned by auth.uid() (see 004_rls_tenant_ownership.sql, 005_despesas.sql).

GRANT SELECT ON public.vw_relatorio_diario_pdf TO authenticated;
GRANT SELECT ON public.vw_relatorio_mensal_pdf TO authenticated;
GRANT SELECT ON public.vw_relatorio_diario_atendimentos_detalhe TO authenticated;
GRANT SELECT ON public.vw_relatorio_diario_despesas_detalhe TO authenticated;
