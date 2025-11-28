-- ============================================================================
-- EXPOR VIEW PARA API: Power BI Dashboard Metrics
-- ============================================================================
-- Garante que a view seja acessível via API REST do Supabase
-- ============================================================================

-- 1. Verificar se a view existe
SELECT
  schemaname,
  viewname
FROM pg_views
WHERE schemaname = 'sales_intelligence'
  AND viewname = 'powerbi_dashboard_metrics';

-- 2. Garantir que o schema está no search_path
ALTER DATABASE postgres SET search_path TO public, sales_intelligence;

-- 3. Grant de permissões para as roles do Supabase
GRANT USAGE ON SCHEMA sales_intelligence TO anon, authenticated;
GRANT SELECT ON sales_intelligence.powerbi_dashboard_metrics TO anon, authenticated;
GRANT SELECT ON sales_intelligence.leads TO anon, authenticated;

-- 4. Verificar se conseguimos fazer SELECT
SELECT
  leads_total,
  leads_qualif_total,
  leads_venda_total,
  taxa_conv_total
FROM sales_intelligence.powerbi_dashboard_metrics;

SELECT '✅ View exposta com sucesso! Teste a API agora.' as status;

-- 5. URL para testar no navegador (substitua YOUR_PROJECT_URL):
-- https://bfumywvwubvernvhjehk.supabase.co/rest/v1/powerbi_dashboard_metrics?select=*
