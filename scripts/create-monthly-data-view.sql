-- ============================================================================
-- CRIAR VIEW DE DADOS MENSAIS PARA TABELA HISTÓRICA
-- ============================================================================
-- Para a página Home - Tabela com scroll horizontal
-- Formato compatível com interface MonthlyData do dashboard
-- ============================================================================

DROP VIEW IF EXISTS public.monthly_data CASCADE;

CREATE VIEW public.monthly_data AS
SELECT
  -- Mês em português
  CASE TO_CHAR(created_at, 'MM')
    WHEN '01' THEN 'Janeiro'
    WHEN '02' THEN 'Fevereiro'
    WHEN '03' THEN 'Março'
    WHEN '04' THEN 'Abril'
    WHEN '05' THEN 'Maio'
    WHEN '06' THEN 'Junho'
    WHEN '07' THEN 'Julho'
    WHEN '08' THEN 'Agosto'
    WHEN '09' THEN 'Setembro'
    WHEN '10' THEN 'Outubro'
    WHEN '11' THEN 'Novembro'
    WHEN '12' THEN 'Dezembro'
  END::TEXT as mes,

  EXTRACT(MONTH FROM created_at)::INTEGER as month_num,

  -- Investimentos (0 até dados disponíveis)
  0::INTEGER as inv_trafego,
  0::INTEGER as inv_bpo,

  -- SAL (total de leads qualificados)
  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as sal,

  -- % Agendados (sobre qualificados)
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(
      COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')),
      0
    ), 0),
    0
  )::INTEGER as pct_agd,

  -- Total de Leads Agendados
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)::INTEGER as leads_agd,

  -- % Calls (reuniões sobre agendados)
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE contacted_at IS NOT NULL
        AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(
      COUNT(*) FILTER (WHERE contacted_at IS NOT NULL),
      0
    ), 0),
    0
  )::INTEGER as pct_calls,

  -- Total de Calls (reuniões realizadas)
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as tt_calls,

  -- % Ganhos (sobre calls)
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(
      COUNT(*) FILTER (
        WHERE contacted_at IS NOT NULL
          AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
      ),
      0
    ), 0),
    0
  )::INTEGER as pct_ganhos,

  -- Total de Ganhos
  COUNT(*) FILTER (WHERE status = 'won')::INTEGER as tt_ganhos,

  -- Agendados TRAF
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as tl_agd_traf,

  -- Agendados BPO
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as tl_agd_bpo,

  -- Calls TRAF
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as calls_traf,

  -- Calls BPO
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as calls_bpo,

  -- Ganhos TRAF
  COUNT(*) FILTER (
    WHERE status = 'won'
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as ganhos_traf,

  -- Ganhos BPO
  COUNT(*) FILTER (
    WHERE status = 'won'
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as ganhos_bpo,

  -- CPL TRAF (custo por lead) - 0 até investimento disponível
  0::NUMERIC as cpl_traf,

  -- CPL BPO
  0::NUMERIC as cpl_bpo,

  -- CPRA TRAF (custo por reunião agendada) - 0 até investimento disponível
  0::NUMERIC as cpra_traf,

  -- CPRA BPO
  0::NUMERIC as cpra_bpo,

  -- CPA TRAF (custo por aquisição) - 0 até investimento disponível
  0::NUMERIC as cpa_traf,

  -- CPA BPO
  0::NUMERIC as cpa_bpo

FROM sales_intelligence.leads
WHERE created_at >= DATE_TRUNC('year', CURRENT_DATE)
  AND status IS NOT NULL
GROUP BY TO_CHAR(created_at, 'MM'), EXTRACT(MONTH FROM created_at)
ORDER BY month_num ASC;

-- Garantir permissões
GRANT SELECT ON public.monthly_data TO anon, authenticated;

-- Testar
SELECT
  mes,
  sal,
  pct_agd,
  leads_agd,
  tt_calls,
  tt_ganhos
FROM public.monthly_data
LIMIT 5;

SELECT '✅ View monthly_data criada! Use em: Página Home (Tabela Histórica)' as status;
