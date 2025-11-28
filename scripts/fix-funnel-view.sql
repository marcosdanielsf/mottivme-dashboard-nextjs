-- ============================================================================
-- FIX: Corrigir view funnel_metrics
-- Problema: l.stage_order não existe na tabela leads
-- Solução: Usar subquery para calcular conversão
-- ============================================================================

DROP VIEW IF EXISTS sales_intelligence.funnel_metrics CASCADE;
DROP VIEW IF EXISTS public.sales_funnel_metrics CASCADE;

CREATE OR REPLACE VIEW sales_intelligence.funnel_metrics AS
SELECT
  fs.id,
  fs.stage_name,
  fs.stage_code,
  fs.stage_order,
  fs.color,

  -- Contadores
  COUNT(l.id) as count,
  COALESCE(SUM(l.estimated_value), 0) as total_estimated_value,
  COALESCE(SUM(l.won_value), 0) as total_won_value,

  -- Percentuais
  ROUND((COUNT(l.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM sales_intelligence.leads), 0)) * 100, 2) as percentage,

  -- Conversão para próxima etapa (NULL para última etapa)
  CASE
    WHEN fs.stage_order < (SELECT MAX(stage_order) FROM sales_intelligence.funnel_stages) THEN
      ROUND((
        (SELECT COUNT(*) FROM sales_intelligence.leads l2
         INNER JOIN sales_intelligence.funnel_stages fs2 ON l2.stage_id = fs2.id
         WHERE fs2.stage_order > fs.stage_order)::NUMERIC
        / NULLIF(COUNT(l.id), 0)
      ) * 100, 2)
    ELSE NULL
  END as conversion_to_next

FROM sales_intelligence.funnel_stages fs
LEFT JOIN sales_intelligence.leads l ON l.stage_id = fs.id
GROUP BY fs.id, fs.stage_name, fs.stage_code, fs.stage_order, fs.color
ORDER BY fs.stage_order;

-- Recriar view pública
CREATE OR REPLACE VIEW public.sales_funnel_metrics AS
SELECT * FROM sales_intelligence.funnel_metrics;

-- Permissões
GRANT SELECT ON public.sales_funnel_metrics TO anon, authenticated, service_role;

SELECT 'View funnel_metrics corrigida com sucesso!' as status;
