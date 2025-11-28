-- ============================================================================
-- CRIAR VIEW DE RANKING DE CLIENTES: client_ranking
-- ============================================================================
-- Para a página: Ranking Clientes
-- ============================================================================

DROP VIEW IF EXISTS public.client_ranking;

CREATE VIEW public.client_ranking AS
SELECT
  ROW_NUMBER() OVER (ORDER BY COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) DESC)::INTEGER as rank,

  -- Nome do Cliente
  COALESCE(client_name, '(Sem Cliente)')::TEXT as cliente,

  -- Lead Qualif (Leads qualificados)
  COUNT(*) FILTER (
    WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')
  )::INTEGER as leadQualif,

  -- Tx Conv (Taxa de conversão de qualificados para agendados)
  CONCAT(
    COALESCE(
      ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) / NULLIF(
        COUNT(*) FILTER (WHERE stage_name IN ('Qualificado', 'Proposta', 'Negociação', 'Ganho')),
        0
      ), 0),
      0
    )::TEXT,
    '%'
  ) as txConv,

  -- Leads Agend (Leads agendados)
  COUNT(*) FILTER (WHERE contacted_at IS NOT NULL)::INTEGER as leadsAgend

FROM sales_intelligence.leads
WHERE client_name IS NOT NULL
  AND status IS NOT NULL
GROUP BY client_name
HAVING COUNT(*) FILTER (WHERE contacted_at IS NOT NULL) > 0  -- Apenas clientes com agendamentos
ORDER BY leadsAgend DESC
LIMIT 10;

-- Garantir permissões
GRANT SELECT ON public.client_ranking TO anon, authenticated;

-- Testar
SELECT * FROM public.client_ranking;

SELECT '✅ View client_ranking criada! Use em: Ranking Clientes' as status;
