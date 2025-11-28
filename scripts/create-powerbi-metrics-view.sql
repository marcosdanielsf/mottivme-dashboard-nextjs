-- ============================================================================
-- VIEW: Métricas no formato Power BI Dashboard
-- ============================================================================
-- Esta view replica EXATAMENTE as métricas calculadas no Power BI
-- para popular o dashboard com os dados corretos
-- ============================================================================

CREATE OR REPLACE VIEW sales_intelligence.powerbi_dashboard_metrics AS
SELECT
  -- =========================================================================
  -- TRÁFEGO (TRAF) - Canal de Marketing Digital
  -- =========================================================================
  COUNT(*) FILTER (WHERE source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    as leads_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  ) as leads_qualif_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND contacted_at IS NOT NULL
  ) as leads_agend_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND contacted_at IS NOT NULL
    AND stage_name = 'Perdido'
    AND lost_reason ILIKE '%no%show%'
  ) as leads_noshow_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND contacted_at IS NOT NULL
    AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  ) as calls_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND status = 'won'
  ) as leads_venda_traf,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
    AND stage_name = 'Perdido'
    AND (lost_reason NOT ILIKE '%no%show%' OR lost_reason IS NULL)
  ) as leads_desqualif_traf,

  -- Percentuais TRAF
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (WHERE source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%'), 0),
    1
  ) as pct_leads_qualif_traf,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ), 0),
    1
  ) as pct_qualif_agend_traf,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
      AND stage_name = 'Perdido'
      AND lost_reason ILIKE '%no%show%'
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
    ), 0),
    1
  ) as pct_agend_noshow_traf,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
    ), 0),
    1
  ) as pct_agend_calls_traf,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND status = 'won'
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ), 0),
    1
  ) as pct_calls_venda_traf,

  -- =========================================================================
  -- OUTBOUND (OTB) - Canal de Vendas Outbound
  -- =========================================================================
  COUNT(*) FILTER (WHERE source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    as leads_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  ) as leads_qualif_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND contacted_at IS NOT NULL
  ) as leads_agend_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND contacted_at IS NOT NULL
    AND stage_name = 'Perdido'
    AND lost_reason ILIKE '%no%show%'
  ) as leads_noshow_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND contacted_at IS NOT NULL
    AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  ) as calls_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND status = 'won'
  ) as leads_venda_otb,

  COUNT(*) FILTER (WHERE
    (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
    AND stage_name = 'Perdido'
  ) as leads_desqualif_otb,

  -- Percentuais OTB
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (WHERE source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%'), 0),
    1
  ) as pct_leads_qualif_otb,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
    ), 0),
    1
  ) as pct_qualif_agend_otb,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
    ), 0),
    1
  ) as pct_agend_calls_otb,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND status = 'won'
    ) / NULLIF(COUNT(*) FILTER (WHERE
      (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
      AND contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ), 0),
    1
  ) as pct_calls_venda_otb,

  -- =========================================================================
  -- TOTAL (TT) - Todos os canais combinados
  -- =========================================================================
  COUNT(*) as leads_total,

  COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho'))
    as leads_qualif_total,

  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)
    as leads_agend_total,

  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name = 'Perdido' AND lost_reason ILIKE '%no%show%')
    as leads_noshow_total,

  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho'))
    as calls_total,

  COUNT(*) FILTER (WHERE status = 'won')
    as leads_venda_total,

  COUNT(*) FILTER (WHERE stage_name = 'Perdido')
    as leads_desqualif_total,

  -- Percentuais TOTAL
  ROUND(100.0 * COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*), 0), 1)
    as pct_leads_qualif_total,

  ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')), 0), 1)
    as pct_qualif_agend_total,

  ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')) / NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL), 0), 1)
    as pct_agend_calls_total,

  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')), 0), 1)
    as pct_calls_venda_total,

  -- Taxa de Conversão Geral
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*), 0), 1) as taxa_conv_total

FROM sales_intelligence.leads
WHERE status != 'deleted';

-- ============================================================================
-- Testar a view
-- ============================================================================
SELECT * FROM sales_intelligence.powerbi_dashboard_metrics;
