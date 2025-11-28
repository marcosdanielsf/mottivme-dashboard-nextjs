-- ============================================================================
-- VIEW SIMPLIFICADA: Métricas Power BI Dashboard
-- ============================================================================
-- Versão simplificada que funciona com os dados atuais
-- ============================================================================

CREATE OR REPLACE VIEW sales_intelligence.powerbi_dashboard_metrics AS
SELECT
  -- =========================================================================
  -- TRÁFEGO (TRAF) - Usando stage_name para identificar o canal
  -- =========================================================================
  COUNT(*) FILTER (WHERE stage_name = 'Lead') as leads_traf,
  COUNT(*) FILTER (WHERE stage_name = 'Qualificado') as leads_qualif_traf,
  COUNT(*) FILTER (WHERE stage_name = 'Contato' OR contacted_at IS NOT NULL) as leads_agend_traf,
  0 as leads_noshow_traf,
  COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação')) as calls_traf,
  COUNT(*) FILTER (WHERE stage_name = 'Ganho' OR status = 'won') as leads_venda_traf,
  COUNT(*) FILTER (WHERE stage_name = 'Perdido' OR status = 'lost') as leads_desqualif_traf,
  0 as investimento_traf,

  -- Percentuais TRAF
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name = 'Qualificado') /
    NULLIF(COUNT(*) FILTER (WHERE stage_name = 'Lead'), 0), 1), 0) as pct_leads_qualif_traf,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name = 'Contato' OR contacted_at IS NOT NULL) /
    NULLIF(COUNT(*) FILTER (WHERE stage_name = 'Qualificado'), 0), 1), 0) as pct_qualif_agend_traf,

  0 as pct_agend_noshow_traf,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação')) /
    NULLIF(COUNT(*) FILTER (WHERE stage_name = 'Contato' OR contacted_at IS NOT NULL), 0), 1), 0) as pct_agend_calls_traf,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name = 'Ganho' OR status = 'won') /
    NULLIF(COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação')), 0), 1), 0) as pct_calls_venda_traf,

  -- =========================================================================
  -- OTB (Outbound) - Por enquanto zerado, ajustar quando tiver dados de canal
  -- =========================================================================
  0 as leads_otb,
  0 as leads_qualif_otb,
  0 as leads_agend_otb,
  0 as leads_noshow_otb,
  0 as calls_otb,
  0 as leads_venda_otb,
  0 as leads_desqualif_otb,
  0 as investimento_otb,

  -- Percentuais OTB
  0 as pct_leads_qualif_otb,
  0 as pct_qualif_agend_otb,
  0 as pct_agend_calls_otb,
  0 as pct_calls_venda_otb,

  -- =========================================================================
  -- TOTAL - Todos os leads
  -- =========================================================================
  COUNT(*) as leads_total,
  COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) as leads_qualif_total,
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) as leads_agend_total,
  0 as leads_noshow_total,
  COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação', 'Ganho')) as calls_total,
  COUNT(*) FILTER (WHERE status = 'won') as leads_venda_total,
  COUNT(*) FILTER (WHERE status = 'lost') as leads_desqualif_total,
  0 as investimento_total,

  -- Percentuais TOTAL
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) /
    NULLIF(COUNT(*), 0), 1), 0) as pct_leads_qualif_total,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) /
    NULLIF(COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')), 0), 1), 0) as pct_qualif_agend_total,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação', 'Ganho')) /
    NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL), 0), 1), 0) as pct_agend_calls_total,

  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') /
    NULLIF(COUNT(*) FILTER (WHERE stage_name IN ('Proposta', 'Negociação', 'Ganho')), 0), 1), 0) as pct_calls_venda_total,

  -- Taxa de Conversão Geral
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*), 0), 1), 0) as taxa_conv_total

FROM sales_intelligence.leads
WHERE status IS NOT NULL;

-- ============================================================================
-- Testar a view
-- ============================================================================
SELECT
  leads_total,
  leads_qualif_total,
  leads_agend_total,
  leads_venda_total,
  pct_leads_qualif_total,
  taxa_conv_total
FROM sales_intelligence.powerbi_dashboard_metrics;

SELECT '✅ View Power BI criada com sucesso!' as status;
