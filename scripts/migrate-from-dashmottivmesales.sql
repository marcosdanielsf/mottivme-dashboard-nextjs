-- ============================================================================
-- MIGRAÇÃO: dashmottivmesales → sales_intelligence
-- Migra dados existentes para o novo schema otimizado
-- ============================================================================

-- ============================================================================
-- PARTE 1: Extrair e popular tabelas dimensão
-- ============================================================================

-- 1.1. Popular USERS (vendedores únicos)
INSERT INTO sales_intelligence.users (user_name, email, role, status)
SELECT DISTINCT
  nome_usuario_responsavel,
  NULL as email, -- Não temos email na tabela original
  'SDR' as role, -- Assumir SDR como padrão
  'active' as status
FROM public.dashmottivmesales
WHERE nome_usuario_responsavel IS NOT NULL
  AND nome_usuario_responsavel <> ''
ON CONFLICT (user_name) DO NOTHING;

-- 1.2. Popular LEAD_SOURCES (fontes únicas)
INSERT INTO sales_intelligence.lead_sources (source_name, source_type, active)
SELECT DISTINCT
  fonte_do_lead_bposs,
  CASE
    WHEN fonte_do_lead_bposs ILIKE '%facebook%' OR fonte_do_lead_bposs ILIKE '%fb%' THEN 'Paid'
    WHEN fonte_do_lead_bposs ILIKE '%google%' THEN 'Paid'
    WHEN fonte_do_lead_bposs ILIKE '%indicação%' OR fonte_do_lead_bposs ILIKE '%indicacao%' THEN 'Referral'
    WHEN fonte_do_lead_bposs ILIKE '%organico%' OR fonte_do_lead_bposs ILIKE '%organic%' THEN 'Organic'
    ELSE 'Direct'
  END as source_type,
  true as active
FROM public.dashmottivmesales
WHERE fonte_do_lead_bposs IS NOT NULL
  AND fonte_do_lead_bposs <> ''
ON CONFLICT (source_name) DO NOTHING;

-- 1.3. Popular FUNNEL_STAGES (etapas únicas do funil)
-- Mapeamento do fluxo_vs para etapas padrão
INSERT INTO sales_intelligence.funnel_stages (stage_name, stage_code, stage_order, color, description)
SELECT DISTINCT
  CASE
    -- Mapear status do fluxo_vs para etapas padrão
    WHEN fluxo_vs ILIKE '%lead%' OR fluxo_vs ILIKE '%novo%' THEN 'Lead'
    WHEN fluxo_vs ILIKE '%contato%' OR fluxo_vs ILIKE '%contactado%' OR fluxo_vs ILIKE '%agendado%' OR fluxo_vs = 'booked' THEN 'Contato'
    WHEN fluxo_vs ILIKE '%qualificado%' OR fluxo_vs ILIKE '%qualified%' THEN 'Qualificado'
    WHEN fluxo_vs ILIKE '%proposta%' OR fluxo_vs ILIKE '%proposal%' THEN 'Proposta'
    WHEN fluxo_vs ILIKE '%negociação%' OR fluxo_vs ILIKE '%negotiation%' THEN 'Negociação'
    WHEN fluxo_vs ILIKE '%ganho%' OR fluxo_vs ILIKE '%won%' OR fluxo_vs ILIKE '%fechado%' OR fluxo_vs = 'won' THEN 'Ganho'
    WHEN fluxo_vs ILIKE '%perdido%' OR fluxo_vs ILIKE '%lost%' OR fluxo_vs = 'lost' THEN 'Perdido'
    ELSE 'Lead'
  END as stage_name,
  UPPER(LEFT(fluxo_vs, 10)) as stage_code,
  CASE
    WHEN fluxo_vs ILIKE '%lead%' OR fluxo_vs ILIKE '%novo%' THEN 1
    WHEN fluxo_vs ILIKE '%contato%' OR fluxo_vs ILIKE '%contactado%' OR fluxo_vs ILIKE '%agendado%' OR fluxo_vs = 'booked' THEN 2
    WHEN fluxo_vs ILIKE '%qualificado%' OR fluxo_vs ILIKE '%qualified%' THEN 3
    WHEN fluxo_vs ILIKE '%proposta%' OR fluxo_vs ILIKE '%proposal%' THEN 4
    WHEN fluxo_vs ILIKE '%negociação%' OR fluxo_vs ILIKE '%negotiation%' THEN 5
    WHEN fluxo_vs ILIKE '%ganho%' OR fluxo_vs ILIKE '%won%' OR fluxo_vs ILIKE '%fechado%' OR fluxo_vs = 'won' THEN 6
    WHEN fluxo_vs ILIKE '%perdido%' OR fluxo_vs ILIKE '%lost%' OR fluxo_vs = 'lost' THEN 7
    ELSE 1
  END as stage_order,
  CASE
    WHEN fluxo_vs ILIKE '%lead%' OR fluxo_vs ILIKE '%novo%' THEN '#3B82F6'
    WHEN fluxo_vs ILIKE '%contato%' OR fluxo_vs ILIKE '%contactado%' OR fluxo_vs ILIKE '%agendado%' OR fluxo_vs = 'booked' THEN '#8B5CF6'
    WHEN fluxo_vs ILIKE '%qualificado%' OR fluxo_vs ILIKE '%qualified%' THEN '#EC4899'
    WHEN fluxo_vs ILIKE '%proposta%' OR fluxo_vs ILIKE '%proposal%' THEN '#F59E0B'
    WHEN fluxo_vs ILIKE '%negociação%' OR fluxo_vs ILIKE '%negotiation%' THEN '#F97316'
    WHEN fluxo_vs ILIKE '%ganho%' OR fluxo_vs ILIKE '%won%' OR fluxo_vs ILIKE '%fechado%' OR fluxo_vs = 'won' THEN '#10B981'
    WHEN fluxo_vs ILIKE '%perdido%' OR fluxo_vs ILIKE '%lost%' OR fluxo_vs = 'lost' THEN '#EF4444'
    ELSE '#3B82F6'
  END as color,
  fluxo_vs as description
FROM public.dashmottivmesales
WHERE fluxo_vs IS NOT NULL
  AND fluxo_vs <> ''
ON CONFLICT (stage_name) DO NOTHING;

-- 1.4. Criar cliente "Mottivme" como padrão (já que não temos coluna de cliente)
INSERT INTO sales_intelligence.clients (client_name, industry, tier, status)
VALUES ('Mottivme - Sales', 'Educação', 'Premium', 'active')
ON CONFLICT (client_name) DO NOTHING;

-- ============================================================================
-- PARTE 2: Migrar LEADS
-- ============================================================================

INSERT INTO sales_intelligence.leads (
  external_id,
  lead_name,
  lead_email,
  lead_phone,

  -- Cliente (usar ID do Mottivme criado acima)
  client_id,
  client_name,

  -- Fonte
  source_id,
  source_name,

  -- Etapa
  stage_id,
  stage_name,

  -- Atribuição
  assigned_user_id,
  assigned_user_name,

  -- Datas
  created_at,
  contacted_at,
  won_at,
  lost_at,

  -- Status
  status,

  -- Localização
  state,

  -- Motivo de perda
  lost_reason,

  -- Observações
  notes,
  tags,

  updated_at
)
SELECT
  d.id::TEXT as external_id,
  COALESCE(d.contato_principal, 'Lead #' || d.id::TEXT) as lead_name,
  d.email_comercial_contato as lead_email,
  COALESCE(d.telefone_comercial_contato, d.celular_contato) as lead_phone,

  -- Cliente (buscar ID do Mottivme)
  (SELECT id FROM sales_intelligence.clients WHERE client_name = 'Mottivme - Sales' LIMIT 1) as client_id,
  'Mottivme - Sales' as client_name,

  -- Fonte (buscar ID pela fonte)
  ls.id as source_id,
  d.fonte_do_lead_bposs as source_name,

  -- Etapa (mapear fluxo_vs para stage)
  fs.id as stage_id,
  fs.stage_name,

  -- Atribuição (buscar ID do usuário)
  u.id as assigned_user_id,
  d.nome_usuario_responsavel as assigned_user_name,

  -- Datas
  d.data_criada as created_at,
  COALESCE(d.data_e_hora_do_agendamento_bposs, d.scheduled_at, d.data_que_o_lead_entrou_na_etapa_de_agendamento) as contacted_at,
  CASE WHEN d.status::TEXT = 'won' OR d.fluxo_vs ILIKE '%ganho%' THEN d.data_da_atualizacao ELSE NULL END as won_at,
  CASE WHEN d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%' THEN d.data_da_atualizacao ELSE NULL END as lost_at,

  -- Status
  CASE
    WHEN d.status::TEXT = 'won' OR d.fluxo_vs ILIKE '%ganho%' THEN 'won'
    WHEN d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%' THEN 'lost'
    ELSE 'active'
  END as status,

  -- Localização
  d.estado_onde_mora_contato as state,

  -- Motivo de perda (usar padrão se NULL e status for lost)
  CASE
    WHEN (d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%') AND d.motivo_do_perdido IS NULL
    THEN 'Não especificado'
    ELSE d.motivo_do_perdido
  END as lost_reason,

  -- Observações (concatenar campos extras)
  CONCAT_WS(E'\n',
    CASE WHEN d.profissao_contato IS NOT NULL THEN 'Profissão: ' || d.profissao_contato END,
    CASE WHEN d.permissao_de_trabalho IS NOT NULL THEN 'Permissão de trabalho: ' || d.permissao_de_trabalho END,
    CASE WHEN d.tipo_do_agendamento IS NOT NULL THEN 'Tipo de agendamento: ' || d.tipo_do_agendamento END,
    CASE WHEN d.chat_channel IS NOT NULL THEN 'Canal: ' || d.chat_channel END
  ) as notes,

  -- Tags (converter string para array)
  CASE
    WHEN d.tag IS NOT NULL AND d.tag <> ''
    THEN ARRAY[d.tag]::VARCHAR(255)[]
    ELSE NULL
  END as tags,

  COALESCE(d.data_da_atualizacao, d.data_criada, NOW()) as updated_at

FROM public.dashmottivmesales d

-- LEFT JOIN com users
LEFT JOIN sales_intelligence.users u
  ON u.user_name = d.nome_usuario_responsavel

-- LEFT JOIN com lead_sources
LEFT JOIN sales_intelligence.lead_sources ls
  ON ls.source_name = d.fonte_do_lead_bposs

-- LEFT JOIN com funnel_stages (mapear fluxo_vs)
LEFT JOIN sales_intelligence.funnel_stages fs ON fs.stage_name =
  CASE
    WHEN d.fluxo_vs ILIKE '%lead%' OR d.fluxo_vs ILIKE '%novo%' THEN 'Lead'
    WHEN d.fluxo_vs ILIKE '%contato%' OR d.fluxo_vs ILIKE '%contactado%' OR d.fluxo_vs ILIKE '%agendado%' OR d.fluxo_vs::TEXT = 'booked' THEN 'Contato'
    WHEN d.fluxo_vs ILIKE '%qualificado%' OR d.fluxo_vs ILIKE '%qualified%' THEN 'Qualificado'
    WHEN d.fluxo_vs ILIKE '%proposta%' OR d.fluxo_vs ILIKE '%proposal%' THEN 'Proposta'
    WHEN d.fluxo_vs ILIKE '%negociação%' OR d.fluxo_vs ILIKE '%negotiation%' THEN 'Negociação'
    WHEN d.fluxo_vs ILIKE '%ganho%' OR d.fluxo_vs ILIKE '%won%' OR d.fluxo_vs ILIKE '%fechado%' OR d.fluxo_vs::TEXT = 'won' THEN 'Ganho'
    WHEN d.fluxo_vs ILIKE '%perdido%' OR d.fluxo_vs ILIKE '%lost%' OR d.fluxo_vs::TEXT = 'lost' THEN 'Perdido'
    ELSE 'Lead'
  END

WHERE d.id IS NOT NULL

-- Evitar duplicatas (caso execute o script 2x)
ON CONFLICT (external_id) DO UPDATE SET
  lead_name = COALESCE(EXCLUDED.lead_name, 'Lead #' || EXCLUDED.external_id),
  lead_email = EXCLUDED.lead_email,
  lead_phone = EXCLUDED.lead_phone,
  source_id = EXCLUDED.source_id,
  source_name = EXCLUDED.source_name,
  stage_id = EXCLUDED.stage_id,
  stage_name = EXCLUDED.stage_name,
  assigned_user_id = EXCLUDED.assigned_user_id,
  assigned_user_name = EXCLUDED.assigned_user_name,
  contacted_at = EXCLUDED.contacted_at,
  won_at = EXCLUDED.won_at,
  lost_at = EXCLUDED.lost_at,
  status = EXCLUDED.status,
  state = EXCLUDED.state,
  lost_reason = EXCLUDED.lost_reason,
  notes = EXCLUDED.notes,
  tags = EXCLUDED.tags,
  updated_at = NOW();

-- ============================================================================
-- PARTE 3: Verificação
-- ============================================================================

SELECT
  '🎉 Migração concluída com sucesso!' as status,
  (SELECT COUNT(*) FROM public.dashmottivmesales) as total_original,
  (SELECT COUNT(*) FROM sales_intelligence.leads) as total_migrado,
  (SELECT COUNT(*) FROM sales_intelligence.users) as total_users,
  (SELECT COUNT(*) FROM sales_intelligence.lead_sources) as total_sources,
  (SELECT COUNT(*) FROM sales_intelligence.funnel_stages) as total_stages;

-- Verificar distribuição por etapa
SELECT
  'Distribuição por Etapa:' as info,
  stage_name,
  COUNT(*) as total_leads
FROM sales_intelligence.leads
GROUP BY stage_name
ORDER BY COUNT(*) DESC;

-- Verificar distribuição por status
SELECT
  'Distribuição por Status:' as info,
  status,
  COUNT(*) as total_leads
FROM sales_intelligence.leads
GROUP BY status;
