-- ============================================================================
-- CRIAR VIEW NO SCHEMA PUBLIC: Power BI Dashboard Metrics
-- ============================================================================
-- O Supabase API só acessa views no schema 'public' por padrão
-- ============================================================================

-- 1. Criar a view no schema public (exposta via API)
DROP VIEW IF EXISTS public.powerbi_dashboard_metrics;

CREATE VIEW public.powerbi_dashboard_metrics AS
SELECT
  -- TRÁFEGO (TRAF)
  COUNT(*) FILTER (WHERE source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')::INTEGER as leads_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho'))::INTEGER as leads_qualif_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL)::INTEGER as leads_agend_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL AND stage_name = 'Perdido' AND lost_reason ILIKE '%no%show%')::INTEGER as leads_noshow_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho'))::INTEGER as calls_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND status = 'won')::INTEGER as leads_venda_traf,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND stage_name = 'Perdido')::INTEGER as leads_desqualif_traf,
  0 as investimento_traf,

  -- Percentuais TRAF
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%'), 0), 1), 0)::INTEGER as pct_leads_qualif_traf,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL) / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_qualif_agend_traf,
  0 as pct_agend_noshow_traf,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL), 0), 1), 0)::INTEGER as pct_agend_calls_traf,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND status = 'won') / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_calls_venda_traf,

  -- OTB (Outbound)
  COUNT(*) FILTER (WHERE source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')::INTEGER as leads_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho'))::INTEGER as leads_qualif_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL)::INTEGER as leads_agend_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL AND stage_name = 'Perdido' AND lost_reason ILIKE '%no%show%')::INTEGER as leads_noshow_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho'))::INTEGER as calls_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND status = 'won')::INTEGER as leads_venda_otb,
  COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND stage_name = 'Perdido')::INTEGER as leads_desqualif_otb,
  0 as investimento_otb,

  -- Percentuais OTB
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%'), 0), 1), 0)::INTEGER as pct_leads_qualif_otb,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL) / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_qualif_agend_otb,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL), 0), 1), 0)::INTEGER as pct_agend_calls_otb,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND status = 'won') / NULLIF(COUNT(*) FILTER (WHERE (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%') AND contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_calls_venda_otb,

  -- TOTAL
  COUNT(*)::INTEGER as leads_total,
  COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho'))::INTEGER as leads_qualif_total,
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)::INTEGER as leads_agend_total,
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name = 'Perdido' AND lost_reason ILIKE '%no%show%')::INTEGER as leads_noshow_total,
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho'))::INTEGER as calls_total,
  COUNT(*) FILTER (WHERE status = 'won')::INTEGER as leads_venda_total,
  COUNT(*) FILTER (WHERE stage_name = 'Perdido')::INTEGER as leads_desqualif_total,
  0 as investimento_total,

  -- Percentuais TOTAL
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*), 0), 1), 0)::INTEGER as pct_leads_qualif_total,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_qualif_agend_total,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL), 0), 1), 0)::INTEGER as pct_agend_calls_total,
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')), 0), 1), 0)::INTEGER as pct_calls_venda_total,

  -- Taxa de Conversão Geral
  COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*), 0), 1), 0)::INTEGER as taxa_conv_total

FROM sales_intelligence.leads
WHERE status IS NOT NULL;

-- 2. Garantir permissões
GRANT SELECT ON public.powerbi_dashboard_metrics TO anon, authenticated;

-- 3. Testar
SELECT
  leads_total,
  leads_venda_total,
  taxa_conv_total
FROM public.powerbi_dashboard_metrics;

SELECT '✅ View criada no schema PUBLIC! Dashboard funcionará agora!' as status;
