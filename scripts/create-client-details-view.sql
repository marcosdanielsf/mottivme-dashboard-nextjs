-- ============================================================================
-- CRIAR VIEW DE DETALHES DE CLIENTES: client_details
-- ============================================================================
-- Para a página: Usuários (tabela detalhada)
-- ============================================================================

DROP VIEW IF EXISTS public.client_details;

CREATE VIEW public.client_details AS
SELECT
  -- Nome do Cliente
  COALESCE(client_name, '(Sem Cliente)')::TEXT as cliente,

  -- Investimento Tráfego (0 até dados estarem disponíveis)
  0 as invTraf,

  -- Investimento BPO (0 até dados estarem disponíveis)
  0 as invBpo,

  -- Ativados (Total de leads do cliente)
  COUNT(*)::INTEGER as ativados,

  -- Tx SQL (Taxa de qualificação)
  CONCAT(
    COALESCE(
      ROUND(100.0 * COUNT(*) FILTER (
        WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
      ) / NULLIF(COUNT(*), 0), 0),
      0
    )::TEXT,
    '%'
  ) as txSql,

  -- Lead Qualif (Leads qualificados)
  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leadQualif,

  -- Tx Agd (Taxa de agendamento sobre qualificados)
  CONCAT(
    COALESCE(
      ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(
        COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')),
        0
      ), 0),
      0
    )::TEXT,
    '%'
  ) as txAgd,

  -- Leads Agend (Leads agendados)
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)::INTEGER as leadsAgend,

  -- Calls (Reuniões realizadas)
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name IN ('Proposta', 'Negociação', 'Ganho')
  )::INTEGER as calls,

  -- Ganhos (Vendas fechadas)
  COUNT(*) FILTER (WHERE status = 'won')::INTEGER as ganhos,

  -- Perdidos
  COUNT(*) FILTER (WHERE stage_name = 'Perdido')::INTEGER as perdidos,

  -- NoShow
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND stage_name = 'Perdido'
      AND lost_reason ILIKE '%no%show%'
  )::INTEGER as noshow,

  -- Leads TRAF
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%facebook%'
       OR source_name ILIKE '%google%'
       OR source_name ILIKE '%ads%'
  )::INTEGER as leadsTraf,

  -- Leads BPO
  COUNT(*) FILTER (
    WHERE source_name ILIKE '%outbound%'
       OR source_name ILIKE '%bpo%'
       OR source_name ILIKE '%cold%'
  )::INTEGER as leadsBpo,

  -- Agendados TRAF
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%facebook%' OR source_name ILIKE '%google%' OR source_name ILIKE '%ads%')
  )::INTEGER as agendTraf,

  -- Agendados BPO
  COUNT(*) FILTER (
    WHERE contacted_at IS NOT NULL
      AND (source_name ILIKE '%outbound%' OR source_name ILIKE '%bpo%' OR source_name ILIKE '%cold%')
  )::INTEGER as agendBpo,

  -- CPL TRAF (0 até investimento estar disponível)
  0 as cplTraf,

  -- CPL BPO (0 até investimento estar disponível)
  0 as cplBpo,

  -- CPRA TRAF (0 até investimento estar disponível)
  0 as cpraTraf,

  -- CPRA BPO (0 até investimento estar disponível)
  0 as cpraBpo,

  -- CPA TRAF (0 até investimento estar disponível)
  0 as cpaTraf,

  -- CPA BPO (0 até investimento estar disponível)
  0 as cpaBpo

FROM sales_intelligence.leads
WHERE client_name IS NOT NULL
  AND status IS NOT NULL
GROUP BY client_name
ORDER BY leadsAgend DESC;

-- Garantir permissões
GRANT SELECT ON public.client_details TO anon, authenticated;

-- Testar
SELECT
  cliente,
  ativados,
  txSql,
  leadQualif,
  txAgd,
  leadsAgend,
  calls
FROM public.client_details
LIMIT 5;

SELECT '✅ View client_details criada! Use em: Página Usuários' as status;
