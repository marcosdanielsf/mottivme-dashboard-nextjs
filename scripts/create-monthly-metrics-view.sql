-- ============================================================================
-- CRIAR VIEW DE MÉTRICAS MENSAIS: monthly_metrics
-- ============================================================================
-- Para as páginas: Evolução e Tabela Histórica da Home
-- ============================================================================

DROP VIEW IF EXISTS public.monthly_metrics;

CREATE VIEW public.monthly_metrics AS
SELECT
  -- Mês
  TO_CHAR(created_at, 'Mon') as month,
  EXTRACT(MONTH FROM created_at)::INTEGER as month_num,
  EXTRACT(YEAR FROM created_at)::INTEGER as year,

  -- Lead Qualif
  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leadQualif,

  -- Taxa de Conversão
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(COUNT(*), 0), 0),
    0
  )::INTEGER as txConv,

  -- Leads Agendados
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)::INTEGER as leadsAgend,

  -- CPA TRAF (será 0 até investimento estar disponível)
  0 as cpaTraf,

  -- CPA BPO (será 0 até investimento estar disponível)
  0 as cpaBpo,

  -- OTB (BPO) Leads
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%outbound%'
       OR source_name ILIKE '%bpo%'
       OR source_name ILIKE '%cold%'
  )::INTEGER as otb,

  -- TRAF (Tráfego) Leads
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%facebook%'
       OR source_name ILIKE '%google%'
       OR source_name ILIKE '%ads%'
  )::INTEGER as traf,

  -- Total de Leads
  COUNT(*)::INTEGER as total,

  -- Investimento Tráfego (0 até dados estarem disponíveis)
  0 as invTrafego,

  -- Investimento BPO (0 até dados estarem disponíveis)
  0 as invBpo,

  -- SAL (Sales Accepted Leads) - Leads qualificados
  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as sal,

  -- % Agendados
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(
      COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')),
      0
    ), 0),
    0
  )::INTEGER as pctAgd,

  -- Leads Agendados TRAF
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as tlAgdTraf,

  -- Leads Agendados BPO
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as tlAgdBpo,

  -- Calls (reuniões realizadas)
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as ttCalls,

  -- % Calls
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (
      WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
    ) / NULLIF(COUNT(*) FILTER (WHERE contacted_at IS NOT NULL), 0), 0),
    0
  )::INTEGER as pctCalls,

  -- Calls TRAF
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as callsTraf,

  -- Calls BPO
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as callsBpo,

  -- Ganhos (Vendas)
  COUNT(*) FILTER (WHERE status = 'won')::INTEGER as ttGanhos,

  -- % Ganhos
  COALESCE(
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'won') / NULLIF(
      COUNT(*) FILTER (WHERE contacted_at IS NOT NULL AND stage_name IN ('Proposta', 'Negociação', 'Ganho')),
      0
    ), 0),
    0
  )::INTEGER as pctGanhos,

  -- Ganhos TRAF
  COUNT(*) FILTER (
    WHERE status = 'won'
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as ganhosTraf,

  -- Ganhos BPO
  COUNT(*) FILTER (
    WHERE status = 'won'
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as ganhosBpo,

  -- CPL TRAF (quando investimento estiver disponível)
  0 as cplTraf,

  -- CPL BPO (quando investimento estiver disponível)
  0 as cplBpo,

  -- CPRA TRAF (quando investimento estiver disponível)
  0 as cpraTraf,

  -- CPRA BPO (quando investimento estiver disponível)
  0 as cpraBpo

FROM sales_intelligence.leads
WHERE created_at >= DATE_TRUNC('year', CURRENT_DATE) -- Apenas ano corrente
  AND status IS NOT NULL
GROUP BY
  TO_CHAR(created_at, 'Mon'),
  EXTRACT(MONTH FROM created_at),
  EXTRACT(YEAR FROM created_at)
ORDER BY year DESC, month_num ASC;

-- Garantir permissões
GRANT SELECT ON public.monthly_metrics TO anon, authenticated;

-- Testar
SELECT
  month,
  leadQualif,
  txConv,
  leadsAgend,
  otb,
  traf,
  total
FROM public.monthly_metrics
ORDER BY month_num
LIMIT 5;

SELECT '✅ View monthly_metrics criada! Use em: Evolução e Tabela Histórica' as status;
