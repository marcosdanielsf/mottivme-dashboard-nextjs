-- ============================================================================
-- AUTO-SYNC: Sincronização Automática dashmottivmesales → sales_intelligence
-- ============================================================================
-- Este script cria triggers que automaticamente sincronizam novos leads
-- da tabela antiga para o novo schema otimizado
-- ============================================================================

-- ============================================================================
-- FUNÇÃO: Sincronizar lead individual
-- ============================================================================

CREATE OR REPLACE FUNCTION sync_lead_from_dashmottivmesales()
RETURNS TRIGGER AS $$
DECLARE
  v_client_id UUID;
  v_source_id UUID;
  v_stage_id UUID;
  v_user_id UUID;
  v_stage_name TEXT;
BEGIN
  -- 1. Buscar ou criar cliente padrão
  SELECT id INTO v_client_id
  FROM sales_intelligence.clients
  WHERE client_name = 'Mottivme - Sales'
  LIMIT 1;

  -- Se não existir, criar
  IF v_client_id IS NULL THEN
    INSERT INTO sales_intelligence.clients (client_name, industry, tier, status)
    VALUES ('Mottivme - Sales', 'Educação', 'Premium', 'active')
    RETURNING id INTO v_client_id;
  END IF;

  -- 2. Buscar ou criar fonte
  IF NEW.fonte_do_lead_bposs IS NOT NULL AND NEW.fonte_do_lead_bposs <> '' THEN
    SELECT id INTO v_source_id
    FROM sales_intelligence.lead_sources
    WHERE source_name = NEW.fonte_do_lead_bposs
    LIMIT 1;

    -- Se não existir, criar
    IF v_source_id IS NULL THEN
      INSERT INTO sales_intelligence.lead_sources (source_name, source_type, active)
      VALUES (
        NEW.fonte_do_lead_bposs,
        CASE
          WHEN NEW.fonte_do_lead_bposs ILIKE '%facebook%' OR NEW.fonte_do_lead_bposs ILIKE '%fb%' THEN 'Paid'
          WHEN NEW.fonte_do_lead_bposs ILIKE '%google%' THEN 'Paid'
          WHEN NEW.fonte_do_lead_bposs ILIKE '%indicação%' OR NEW.fonte_do_lead_bposs ILIKE '%indicacao%' THEN 'Referral'
          WHEN NEW.fonte_do_lead_bposs ILIKE '%organico%' OR NEW.fonte_do_lead_bposs ILIKE '%organic%' THEN 'Organic'
          ELSE 'Direct'
        END,
        true
      )
      RETURNING id INTO v_source_id;
    END IF;
  END IF;

  -- 3. Mapear fluxo_vs para stage_name
  v_stage_name := CASE
    WHEN NEW.fluxo_vs ILIKE '%lead%' OR NEW.fluxo_vs ILIKE '%novo%' THEN 'Lead'
    WHEN NEW.fluxo_vs ILIKE '%contato%' OR NEW.fluxo_vs ILIKE '%contactado%' OR NEW.fluxo_vs ILIKE '%agendado%' OR NEW.fluxo_vs::TEXT = 'booked' THEN 'Contato'
    WHEN NEW.fluxo_vs ILIKE '%qualificado%' OR NEW.fluxo_vs ILIKE '%qualified%' THEN 'Qualificado'
    WHEN NEW.fluxo_vs ILIKE '%proposta%' OR NEW.fluxo_vs ILIKE '%proposal%' THEN 'Proposta'
    WHEN NEW.fluxo_vs ILIKE '%negociação%' OR NEW.fluxo_vs ILIKE '%negotiation%' THEN 'Negociação'
    WHEN NEW.fluxo_vs ILIKE '%ganho%' OR NEW.fluxo_vs ILIKE '%won%' OR NEW.fluxo_vs ILIKE '%fechado%' OR NEW.fluxo_vs::TEXT = 'won' THEN 'Ganho'
    WHEN NEW.fluxo_vs ILIKE '%perdido%' OR NEW.fluxo_vs ILIKE '%lost%' OR NEW.fluxo_vs::TEXT = 'lost' THEN 'Perdido'
    ELSE 'Lead'
  END;

  -- 4. Buscar stage_id
  SELECT id INTO v_stage_id
  FROM sales_intelligence.funnel_stages
  WHERE stage_name = v_stage_name
  LIMIT 1;

  -- 5. Buscar ou criar usuário
  IF NEW.nome_usuario_responsavel IS NOT NULL AND NEW.nome_usuario_responsavel <> '' THEN
    SELECT id INTO v_user_id
    FROM sales_intelligence.users
    WHERE user_name = NEW.nome_usuario_responsavel
    LIMIT 1;

    -- Se não existir, criar
    IF v_user_id IS NULL THEN
      INSERT INTO sales_intelligence.users (user_name, email, role, status)
      VALUES (NEW.nome_usuario_responsavel, NULL, 'SDR', 'active')
      RETURNING id INTO v_user_id;
    END IF;
  END IF;

  -- 6. Inserir ou atualizar lead
  INSERT INTO sales_intelligence.leads (
    external_id,
    lead_name,
    lead_email,
    lead_phone,
    client_id,
    client_name,
    source_id,
    source_name,
    stage_id,
    stage_name,
    assigned_user_id,
    assigned_user_name,
    created_at,
    contacted_at,
    won_at,
    lost_at,
    status,
    state,
    lost_reason,
    notes,
    tags,
    updated_at
  )
  VALUES (
    NEW.id::TEXT,
    COALESCE(NEW.contato_principal, 'Lead #' || NEW.id::TEXT),
    NEW.email_comercial_contato,
    COALESCE(NEW.telefone_comercial_contato, NEW.celular_contato),
    v_client_id,
    'Mottivme - Sales',
    v_source_id,
    NEW.fonte_do_lead_bposs,
    v_stage_id,
    v_stage_name,
    v_user_id,
    NEW.nome_usuario_responsavel,
    NEW.data_criada,
    COALESCE(NEW.data_e_hora_do_agendamento_bposs, NEW.scheduled_at, NEW.data_que_o_lead_entrou_na_etapa_de_agendamento),
    CASE WHEN NEW.status::TEXT = 'won' OR NEW.fluxo_vs ILIKE '%ganho%' THEN NEW.data_da_atualizacao ELSE NULL END,
    CASE WHEN NEW.status::TEXT = 'lost' OR NEW.fluxo_vs ILIKE '%perdido%' THEN NEW.data_da_atualizacao ELSE NULL END,
    CASE
      WHEN NEW.status::TEXT = 'won' OR NEW.fluxo_vs ILIKE '%ganho%' THEN 'won'
      WHEN NEW.status::TEXT = 'lost' OR NEW.fluxo_vs ILIKE '%perdido%' THEN 'lost'
      ELSE 'active'
    END,
    NEW.estado_onde_mora_contato,
    CASE
      WHEN (NEW.status::TEXT = 'lost' OR NEW.fluxo_vs ILIKE '%perdido%') AND NEW.motivo_do_perdido IS NULL
      THEN 'Não especificado'
      ELSE NEW.motivo_do_perdido
    END,
    CONCAT_WS(E'\n',
      CASE WHEN NEW.profissao_contato IS NOT NULL THEN 'Profissão: ' || NEW.profissao_contato END,
      CASE WHEN NEW.permissao_de_trabalho IS NOT NULL THEN 'Permissão de trabalho: ' || NEW.permissao_de_trabalho END,
      CASE WHEN NEW.tipo_do_agendamento IS NOT NULL THEN 'Tipo de agendamento: ' || NEW.tipo_do_agendamento END,
      CASE WHEN NEW.chat_channel IS NOT NULL THEN 'Canal: ' || NEW.chat_channel END
    ),
    CASE
      WHEN NEW.tag IS NOT NULL AND NEW.tag <> ''
      THEN ARRAY[NEW.tag]::TEXT[]
      ELSE NULL
    END,
    COALESCE(NEW.data_da_atualizacao, NEW.data_criada, NOW())
  )
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

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Sincronizar ao inserir novo lead
-- ============================================================================

DROP TRIGGER IF EXISTS sync_new_lead_trigger ON public.dashmottivmesales;

CREATE TRIGGER sync_new_lead_trigger
  AFTER INSERT ON public.dashmottivmesales
  FOR EACH ROW
  EXECUTE FUNCTION sync_lead_from_dashmottivmesales();

-- ============================================================================
-- TRIGGER: Sincronizar ao atualizar lead existente
-- ============================================================================

DROP TRIGGER IF EXISTS sync_updated_lead_trigger ON public.dashmottivmesales;

CREATE TRIGGER sync_updated_lead_trigger
  AFTER UPDATE ON public.dashmottivmesales
  FOR EACH ROW
  EXECUTE FUNCTION sync_lead_from_dashmottivmesales();

-- ============================================================================
-- Confirmação
-- ============================================================================

SELECT
  '✅ Triggers de sincronização automática criados com sucesso!' as status,
  'Agora todos os INSERT e UPDATE em dashmottivmesales serão automaticamente sincronizados para sales_intelligence.leads' as info;

-- ============================================================================
-- TESTE (opcional - descomente para testar)
-- ============================================================================

-- Inserir um lead de teste para verificar se o trigger funciona:
/*
INSERT INTO public.dashmottivmesales (
  contato_principal,
  email_comercial_contato,
  telefone_comercial_contato,
  fonte_do_lead_bposs,
  fluxo_vs,
  nome_usuario_responsavel,
  status,
  data_criada,
  data_da_atualizacao
) VALUES (
  'Lead Teste Auto-Sync',
  'teste@autosync.com',
  '11999999999',
  'Facebook Ads - Teste',
  'novo',
  'Vendedor Teste',
  'active',
  NOW(),
  NOW()
);

-- Verificar se foi sincronizado:
SELECT * FROM sales_intelligence.leads
WHERE lead_name = 'Lead Teste Auto-Sync'
ORDER BY created_at DESC
LIMIT 1;
*/
