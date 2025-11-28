-- ============================================================================
-- CRIAR VIEW DE MÉTRICAS DO DASHBOARD PRINCIPAL
-- ============================================================================
-- Para a página: Home (funil TRÁFEGO/BPO/TOTAL + tabela mensal)
-- ============================================================================

DROP VIEW IF EXISTS public.powerbi_dashboard_metrics;

CREATE VIEW public.powerbi_dashboard_metrics AS
SELECT
  -- ============= TRÁFEGO =============
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%facebook%'
       OR source_name ILIKE '%google%'
       OR source_name ILIKE '%ads%'
  )::INTEGER as leads_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leads_qualif_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
  )::INTEGER as leads_agend_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
      AND stage_name = 'Perdido'
      AND lost_reason ILIKE '%no%show%'
  )::INTEGER as leads_noshow_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as calls_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND status = 'won'
  )::INTEGER as leads_venda_traf,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND stage_name = 'Perdido'
  )::INTEGER as leads_desqualif_traf,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (
      WHERE source_name ILIKE '%facebook%'
         OR source_name ILIKE '%google%'
         OR source_name ILIKE '%ads%'
    ), 0), 0),
    0
  )::INTEGER as pct_leads_qualif_traf,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND contacted_at IS NOT NULL
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ), 0), 0),
    0
  )::INTEGER as pct_qualif_agend_traf,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND contacted_at IS NOT NULL
        AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND contacted_at IS NOT NULL
    ), 0), 0),
    0
  )::INTEGER as pct_agend_calls_traf,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND status = 'won'
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
        AND contacted_at IS NOT NULL
        AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ), 0), 0),
    0
  )::INTEGER as pct_calls_venda_traf,

  -- ============= BPO/OTB =============
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%outbound%'
       OR source_name ILIKE '%bpo%'
       OR source_name ILIKE '%cold%'
  )::INTEGER as prospec_otb,

  COUNT(*) FILTER (
    WHERE source_name ILIKE '%outbound%'
       OR source_name ILIKE '%bpo%'
       OR source_name ILIKE '%cold%'
  )::INTEGER as leads_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leads_qualif_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
  )::INTEGER as leads_agend_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
      AND stage_name = 'Perdido'
      AND lost_reason ILIKE '%no%show%'
  )::INTEGER as leads_noshow_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as calls_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND status = 'won'
  )::INTEGER as leads_venda_otb,

  COUNT(*) FILTER (
    WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND stage_name = 'Perdido'
  )::INTEGER as leads_desqualif_otb,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (
      WHERE source_name ILIKE '%outbound%'
         OR source_name ILIKE '%bpo%'
         OR source_name ILIKE '%cold%'
    ), 0), 0),
    0
  )::INTEGER as pct_leads_qualif_otb,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND contacted_at IS NOT NULL
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ), 0), 0),
    0
  )::INTEGER as pct_qualif_agend_otb,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND contacted_at IS NOT NULL
        AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND contacted_at IS NOT NULL
    ), 0), 0),
    0
  )::INTEGER as pct_agend_calls_otb,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND status = 'won'
    ) / NULLIF(COUNT(*) FILTER (
      WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
        AND contacted_at IS NOT NULL
        AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ), 0), 0),
    0
  )::INTEGER as pct_calls_venda_otb,

  -- ============= TOTAL =============
  COUNT(*)::INTEGER as leads_total,

  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leads_qualif_total,

  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
  )::INTEGER as leads_agend_total,

  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as calls_total,

  COUNT(*) FILTER (
    WHERE status = 'won'
  )::INTEGER as leads_venda_total,

  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name = 'Perdido'
      AND lost_reason ILIKE '%no%show%'
  )::INTEGER as noshow_total,

  COUNT(*) FILTER (
    WHERE stage_name = 'Perdido'
  )::INTEGER as perdido_total,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*), 0), 2),
    0
  )::DECIMAL as taxa_conv_total,

  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*), 0), 0),
    0
  )::INTEGER as pct_leads_qualif_total,

  NOW() as updated_at

FROM sales_intelligence.leads
WHERE status IS NOT NULL;

-- Garantir permissões
GRANT SELECT ON public.powerbi_dashboard_metrics TO anon, authenticated;

-- Testar
SELECT
  leads_traf,
  leads_qualif_traf,
  pct_leads_qualif_traf,
  leads_otb,
  leads_qualif_otb,
  pct_leads_qualif_otb,
  leads_total,
  taxa_conv_total
FROM public.powerbi_dashboard_metrics;

SELECT '✅ View powerbi_dashboard_metrics criada! Use em: Página Home' as status;
