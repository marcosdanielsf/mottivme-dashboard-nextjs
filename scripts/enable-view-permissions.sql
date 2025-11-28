-- ============================================================================
-- HABILITAR PERMISSÕES: Power BI Dashboard Metrics View
-- ============================================================================
-- Permite que a view seja acessada via API do Supabase
-- ============================================================================

-- 1. Habilitar RLS na view (mesmo que seja uma view, precisa ter RLS habilitado)
ALTER VIEW sales_intelligence.powerbi_dashboard_metrics SET (security_invoker = true);

-- 2. Criar política de acesso público para leitura
DROP POLICY IF EXISTS "Enable read access for all users" ON sales_intelligence.powerbi_dashboard_metrics;

-- Como é uma VIEW, vamos garantir que a tabela base (leads) tem as permissões corretas
-- Verificar se RLS está habilitado na tabela leads
ALTER TABLE sales_intelligence.leads ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir SELECT público na tabela leads
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON sales_intelligence.leads;

CREATE POLICY "Enable read access for authenticated users"
ON sales_intelligence.leads
FOR SELECT
TO authenticated
USING (true);

-- Também permitir para usuários anônimos (anon role)
DROP POLICY IF EXISTS "Enable read access for anon users" ON sales_intelligence.leads;

CREATE POLICY "Enable read access for anon users"
ON sales_intelligence.leads
FOR SELECT
TO anon
USING (true);

-- ============================================================================
-- Testar se funciona
-- ============================================================================
SELECT
  'leads_total' as metric,
  leads_total as value
FROM sales_intelligence.powerbi_dashboard_metrics;

SELECT '✅ Permissões configuradas! A view agora está acessível via API.' as status;
