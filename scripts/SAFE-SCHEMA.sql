-- ============================================================================
-- SCHEMA SUPER SEGURO - SEM LIMITES APERTADOS
-- Todos os VARCHARs com tamanhos generosos para NUNCA dar erro
-- ============================================================================

DROP SCHEMA IF EXISTS sales_intelligence CASCADE;
DROP VIEW IF EXISTS public.sales_leads CASCADE;
DROP VIEW IF EXISTS public.sales_kpi_metrics CASCADE;
DROP VIEW IF EXISTS public.sales_ranking_users CASCADE;
DROP VIEW IF EXISTS public.sales_ranking_clients CASCADE;
DROP VIEW IF EXISTS public.sales_funnel_metrics CASCADE;
DROP VIEW IF EXISTS public.sales_evolution_daily CASCADE;
DROP VIEW IF EXISTS public.sales_source_performance CASCADE;

CREATE SCHEMA sales_intelligence;

-- CLIENTES
CREATE TABLE sales_intelligence.clients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_name TEXT UNIQUE NOT NULL,
  client_code TEXT,
  industry TEXT,
  tier VARCHAR(50),
  contact_email TEXT,
  contact_phone TEXT,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- USUÁRIOS
CREATE TABLE sales_intelligence.users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_name TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE,
  role VARCHAR(50),
  team TEXT,
  status VARCHAR(50) DEFAULT 'active',
  hired_at DATE,
  terminated_at DATE,
  monthly_goal INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ETAPAS DO FUNIL
CREATE TABLE sales_intelligence.funnel_stages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stage_name TEXT UNIQUE NOT NULL,
  stage_code TEXT,
  stage_order INTEGER NOT NULL UNIQUE,
  color VARCHAR(20),
  icon VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  requires_contact BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FONTES DE LEADS
CREATE TABLE sales_intelligence.lead_sources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  source_name TEXT UNIQUE NOT NULL,
  source_code TEXT,
  source_type VARCHAR(50),
  cost_per_lead DECIMAL(10,2),
  monthly_budget DECIMAL(10,2),
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CALENDÁRIO
CREATE TABLE sales_intelligence.calendar (
  date DATE PRIMARY KEY,
  year INTEGER NOT NULL,
  year_name VARCHAR(10),
  quarter INTEGER,
  quarter_name VARCHAR(10),
  month INTEGER,
  month_name VARCHAR(20),
  month_short VARCHAR(3),
  week INTEGER,
  week_of_month INTEGER,
  day_of_month INTEGER,
  day_of_week INTEGER,
  day_name VARCHAR(20),
  day_short VARCHAR(3),
  is_weekend BOOLEAN DEFAULT false,
  is_holiday BOOLEAN DEFAULT false,
  is_business_day BOOLEAN DEFAULT true,
  holiday_name TEXT
);

-- LEADS (PRINCIPAL) - TUDO EM TEXT PARA NUNCA DAR ERRO
CREATE TABLE sales_intelligence.leads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  external_id TEXT UNIQUE,
  lead_name TEXT NOT NULL,
  lead_email TEXT,
  lead_phone TEXT,
  lead_company TEXT,
  client_id UUID REFERENCES sales_intelligence.clients(id),
  client_name TEXT,
  source_id UUID REFERENCES sales_intelligence.lead_sources(id),
  source_name TEXT,
  stage_id UUID REFERENCES sales_intelligence.funnel_stages(id),
  stage_name TEXT,
  assigned_user_id UUID REFERENCES sales_intelligence.users(id),
  assigned_user_name TEXT,
  scheduled_by_user_id UUID REFERENCES sales_intelligence.users(id),
  scheduled_by_user_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  contacted_at TIMESTAMPTZ,
  qualified_at TIMESTAMPTZ,
  proposal_sent_at TIMESTAMPTZ,
  won_at TIMESTAMPTZ,
  lost_at TIMESTAMPTZ,
  estimated_value DECIMAL(10,2),
  won_value DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'active',
  priority VARCHAR(20),
  country VARCHAR(3) DEFAULT 'USA',
  state TEXT,
  city TEXT,
  days_in_funnel INTEGER,
  days_to_contact INTEGER,
  days_to_qualify INTEGER,
  days_to_close INTEGER,
  conversion_probability DECIMAL(5,2),
  lost_reason TEXT,
  lost_notes TEXT,
  notes TEXT,
  tags TEXT[],
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leads_client_id ON sales_intelligence.leads(client_id);
CREATE INDEX idx_leads_source_id ON sales_intelligence.leads(source_id);
CREATE INDEX idx_leads_stage_id ON sales_intelligence.leads(stage_id);
CREATE INDEX idx_leads_assigned_user_id ON sales_intelligence.leads(assigned_user_id);
CREATE INDEX idx_leads_status ON sales_intelligence.leads(status);
CREATE INDEX idx_leads_created_at ON sales_intelligence.leads(created_at DESC);

-- INVESTIMENTOS
CREATE TABLE sales_intelligence.investments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES sales_intelligence.clients(id),
  client_name TEXT,
  investment_type TEXT NOT NULL,
  category VARCHAR(50),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- POPULAR CALENDÁRIO
INSERT INTO sales_intelligence.calendar (
  date, year, year_name, quarter, quarter_name,
  month, month_name, month_short, week, day_of_month, day_of_week,
  day_name, day_short, is_weekend
)
SELECT
  d::date,
  EXTRACT(YEAR FROM d)::INTEGER,
  EXTRACT(YEAR FROM d)::VARCHAR,
  EXTRACT(QUARTER FROM d)::INTEGER,
  'Q' || EXTRACT(QUARTER FROM d) || ' ' || EXTRACT(YEAR FROM d),
  EXTRACT(MONTH FROM d)::INTEGER,
  CASE EXTRACT(MONTH FROM d)
    WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
    WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
    WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
    WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
  END,
  CASE EXTRACT(MONTH FROM d)
    WHEN 1 THEN 'Jan' WHEN 2 THEN 'Fev' WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Abr' WHEN 5 THEN 'Mai' WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul' WHEN 8 THEN 'Ago' WHEN 9 THEN 'Set'
    WHEN 10 THEN 'Out' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dez'
  END,
  EXTRACT(WEEK FROM d)::INTEGER,
  EXTRACT(DAY FROM d)::INTEGER,
  EXTRACT(DOW FROM d)::INTEGER,
  CASE EXTRACT(DOW FROM d)
    WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda-feira' WHEN 2 THEN 'Terça-feira'
    WHEN 3 THEN 'Quarta-feira' WHEN 4 THEN 'Quinta-feira'
    WHEN 5 THEN 'Sexta-feira' WHEN 6 THEN 'Sábado'
  END,
  CASE EXTRACT(DOW FROM d)
    WHEN 0 THEN 'Dom' WHEN 1 THEN 'Seg' WHEN 2 THEN 'Ter'
    WHEN 3 THEN 'Qua' WHEN 4 THEN 'Qui' WHEN 5 THEN 'Sex' WHEN 6 THEN 'Sáb'
  END,
  EXTRACT(DOW FROM d) IN (0, 6)
FROM generate_series('2020-01-01'::date, '2030-12-31'::date, '1 day') d
ON CONFLICT DO NOTHING;

UPDATE sales_intelligence.calendar SET is_business_day = NOT is_weekend;

-- POPULAR ETAPAS
INSERT INTO sales_intelligence.funnel_stages (stage_name, stage_code, stage_order, color, description) VALUES
  ('Lead', 'LEAD', 1, '#3B82F6', 'Lead novo'),
  ('Contato', 'CONTACT', 2, '#8B5CF6', 'Primeiro contato'),
  ('Qualificado', 'QUALIFIED', 3, '#EC4899', 'Lead qualificado'),
  ('Proposta', 'PROPOSAL', 4, '#F59E0B', 'Proposta enviada'),
  ('Negociação', 'NEGOTIATION', 5, '#F97316', 'Em negociação'),
  ('Ganho', 'WON', 6, '#10B981', 'Venda fechada'),
  ('Perdido', 'LOST', 7, '#EF4444', 'Perdido')
ON CONFLICT DO NOTHING;

-- POPULAR FONTES
INSERT INTO sales_intelligence.lead_sources (source_name, source_code, source_type, cost_per_lead) VALUES
  ('Facebook Ads', 'FB_ADS', 'Paid', 15.00),
  ('Google Ads', 'GOOGLE_ADS', 'Paid', 25.00),
  ('LinkedIn Ads', 'LINKEDIN_ADS', 'Paid', 45.00),
  ('Instagram', 'INSTAGRAM', 'Organic', 0.00),
  ('Indicação', 'REFERRAL', 'Referral', 0.00),
  ('Website', 'WEBSITE', 'Organic', 0.00)
ON CONFLICT DO NOTHING;

-- TRIGGERS
CREATE OR REPLACE FUNCTION sales_intelligence.update_lead_metrics()
RETURNS TRIGGER AS $$
BEGIN
  NEW.days_in_funnel = EXTRACT(DAY FROM (NOW() - NEW.created_at))::INTEGER;
  IF NEW.contacted_at IS NOT NULL AND OLD.contacted_at IS NULL THEN
    NEW.days_to_contact = EXTRACT(DAY FROM (NEW.contacted_at - NEW.created_at))::INTEGER;
  END IF;
  IF NEW.qualified_at IS NOT NULL AND OLD.qualified_at IS NULL THEN
    NEW.days_to_qualify = EXTRACT(DAY FROM (NEW.qualified_at - NEW.created_at))::INTEGER;
  END IF;
  IF NEW.won_at IS NOT NULL AND OLD.won_at IS NULL THEN
    NEW.days_to_close = EXTRACT(DAY FROM (NEW.won_at - NEW.created_at))::INTEGER;
  END IF;
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lead_metrics_trigger
BEFORE UPDATE ON sales_intelligence.leads
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_lead_metrics();

-- VIEWS DE MÉTRICAS
CREATE OR REPLACE VIEW sales_intelligence.kpi_metrics AS
SELECT
  COUNT(*) as total_leads,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as leads_today,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as leads_7d,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as leads_30d,
  COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)) as leads_month,
  COUNT(*) FILTER (WHERE status = 'active') as active_leads,
  COUNT(*) FILTER (WHERE status = 'won') as total_won,
  COUNT(*) FILTER (WHERE status = 'lost') as total_lost,
  ROUND((COUNT(*) FILTER (WHERE status = 'won')::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 2) as conversion_rate,
  ROUND((COUNT(*) FILTER (WHERE status = 'won' AND won_at >= DATE_TRUNC('month', CURRENT_DATE))::NUMERIC /
    NULLIF(COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)), 0)) * 100, 2) as conversion_rate_month,
  SUM(won_value) as total_revenue,
  SUM(won_value) FILTER (WHERE won_at >= CURRENT_DATE) as revenue_today,
  SUM(won_value) FILTER (WHERE won_at >= DATE_TRUNC('month', CURRENT_DATE)) as revenue_month,
  ROUND(AVG(won_value), 2) as avg_ticket,
  ROUND(AVG(won_value) FILTER (WHERE won_at >= DATE_TRUNC('month', CURRENT_DATE)), 2) as avg_ticket_month,
  ROUND(AVG(days_to_contact) FILTER (WHERE contacted_at IS NOT NULL), 1) as avg_days_to_contact,
  ROUND(AVG(days_to_qualify) FILTER (WHERE qualified_at IS NOT NULL), 1) as avg_days_to_qualify,
  ROUND(AVG(days_to_close) FILTER (WHERE status = 'won'), 1) as avg_days_to_close,
  ROUND(AVG(days_in_funnel) FILTER (WHERE status = 'active'), 1) as avg_days_in_funnel_active,
  COUNT(*) FILTER (WHERE stage_name = 'Lead') as stage_lead,
  COUNT(*) FILTER (WHERE stage_name = 'Contato') as stage_contact,
  COUNT(*) FILTER (WHERE stage_name = 'Qualificado') as stage_qualified,
  COUNT(*) FILTER (WHERE stage_name = 'Proposta') as stage_proposal,
  COUNT(*) FILTER (WHERE stage_name = 'Negociação') as stage_negotiation,
  COUNT(*) FILTER (WHERE stage_name = 'Ganho') as stage_won,
  COUNT(*) FILTER (WHERE stage_name = 'Perdido') as stage_lost
FROM sales_intelligence.leads;

CREATE OR REPLACE VIEW sales_intelligence.funnel_metrics AS
SELECT
  fs.id,
  fs.stage_name,
  fs.stage_code,
  fs.stage_order,
  fs.color,
  COUNT(l.id) as count,
  COALESCE(SUM(l.estimated_value), 0) as total_estimated_value,
  COALESCE(SUM(l.won_value), 0) as total_won_value,
  ROUND((COUNT(l.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM sales_intelligence.leads), 0)) * 100, 2) as percentage,
  NULL::NUMERIC as conversion_to_next
FROM sales_intelligence.funnel_stages fs
LEFT JOIN sales_intelligence.leads l ON l.stage_id = fs.id
GROUP BY fs.id, fs.stage_name, fs.stage_code, fs.stage_order, fs.color
ORDER BY fs.stage_order;

CREATE OR REPLACE VIEW sales_intelligence.evolution_daily AS
SELECT
  c.date,
  c.day_name,
  c.is_weekend,
  COUNT(l.id) as leads_created,
  COALESCE(SUM(l.estimated_value), 0) as estimated_value,
  COUNT(l.id) FILTER (WHERE DATE(l.contacted_at) = c.date) as leads_contacted,
  COUNT(l.id) FILTER (WHERE DATE(l.won_at) = c.date) as leads_won,
  COALESCE(SUM(l.won_value) FILTER (WHERE DATE(l.won_at) = c.date), 0) as revenue,
  COUNT(l.id) FILTER (WHERE DATE(l.lost_at) = c.date) as leads_lost
FROM sales_intelligence.calendar c
LEFT JOIN sales_intelligence.leads l ON DATE(l.created_at) = c.date
WHERE c.date >= CURRENT_DATE - INTERVAL '90 days' AND c.date <= CURRENT_DATE
GROUP BY c.date, c.day_name, c.is_weekend
ORDER BY c.date DESC;

-- VIEWS PÚBLICAS
CREATE OR REPLACE VIEW public.sales_kpi_metrics AS SELECT * FROM sales_intelligence.kpi_metrics;
CREATE OR REPLACE VIEW public.sales_funnel_metrics AS SELECT * FROM sales_intelligence.funnel_metrics;
CREATE OR REPLACE VIEW public.sales_evolution_daily AS SELECT * FROM sales_intelligence.evolution_daily;

-- PERMISSÕES
GRANT USAGE ON SCHEMA sales_intelligence TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sales_intelligence TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_kpi_metrics TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_funnel_metrics TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_evolution_daily TO anon, authenticated, service_role;

SELECT '✅ Schema SEGURO criado!' as status;

-- ============================================================================
-- MIGRAÇÃO DE DADOS
-- ============================================================================

-- Popular users
INSERT INTO sales_intelligence.users (user_name, role, status)
SELECT DISTINCT nome_usuario_responsavel, 'SDR', 'active'
FROM public.dashmottivmesales
WHERE nome_usuario_responsavel IS NOT NULL AND nome_usuario_responsavel <> ''
ON CONFLICT DO NOTHING;

-- Popular sources
INSERT INTO sales_intelligence.lead_sources (source_name, source_type, active)
SELECT DISTINCT
  fonte_do_lead_bposs,
  CASE
    WHEN fonte_do_lead_bposs ILIKE '%facebook%' OR fonte_do_lead_bposs ILIKE '%fb%' THEN 'Paid'
    WHEN fonte_do_lead_bposs ILIKE '%google%' THEN 'Paid'
    WHEN fonte_do_lead_bposs ILIKE '%indicação%' THEN 'Referral'
    ELSE 'Direct'
  END,
  true
FROM public.dashmottivmesales
WHERE fonte_do_lead_bposs IS NOT NULL AND fonte_do_lead_bposs <> ''
ON CONFLICT DO NOTHING;

-- Popular stages adicionais
INSERT INTO sales_intelligence.funnel_stages (stage_name, stage_code, stage_order, color, description)
SELECT DISTINCT
  CASE
    WHEN fluxo_vs ILIKE '%lead%' OR fluxo_vs ILIKE '%novo%' THEN 'Lead'
    WHEN fluxo_vs ILIKE '%contato%' OR fluxo_vs ILIKE '%agendado%' OR fluxo_vs = 'booked' THEN 'Contato'
    WHEN fluxo_vs ILIKE '%qualificado%' THEN 'Qualificado'
    WHEN fluxo_vs ILIKE '%proposta%' THEN 'Proposta'
    WHEN fluxo_vs ILIKE '%negociação%' THEN 'Negociação'
    WHEN fluxo_vs ILIKE '%ganho%' OR fluxo_vs = 'won' THEN 'Ganho'
    WHEN fluxo_vs ILIKE '%perdido%' OR fluxo_vs = 'lost' THEN 'Perdido'
    ELSE 'Lead'
  END,
  LEFT(fluxo_vs, 10),
  CASE
    WHEN fluxo_vs ILIKE '%lead%' OR fluxo_vs ILIKE '%novo%' THEN 1
    WHEN fluxo_vs ILIKE '%contato%' OR fluxo_vs ILIKE '%agendado%' OR fluxo_vs = 'booked' THEN 2
    WHEN fluxo_vs ILIKE '%qualificado%' THEN 3
    WHEN fluxo_vs ILIKE '%proposta%' THEN 4
    WHEN fluxo_vs ILIKE '%negociação%' THEN 5
    WHEN fluxo_vs ILIKE '%ganho%' OR fluxo_vs = 'won' THEN 6
    ELSE 7
  END,
  '#3B82F6',
  fluxo_vs
FROM public.dashmottivmesales
WHERE fluxo_vs IS NOT NULL AND fluxo_vs <> ''
ON CONFLICT DO NOTHING;

-- Criar cliente padrão
INSERT INTO sales_intelligence.clients (client_name, industry, tier, status)
VALUES ('Mottivme - Sales', 'Educação', 'Premium', 'active')
ON CONFLICT DO NOTHING;

-- Migrar LEADS
INSERT INTO sales_intelligence.leads (
  external_id, lead_name, lead_email, lead_phone,
  client_id, client_name, source_id, source_name,
  stage_id, stage_name, assigned_user_id, assigned_user_name,
  created_at, contacted_at, won_at, lost_at, status, state, lost_reason, notes, tags, updated_at
)
SELECT
  d.id::TEXT,
  COALESCE(d.contato_principal, 'Lead #' || d.id::TEXT),
  d.email_comercial_contato,
  COALESCE(d.telefone_comercial_contato, d.celular_contato),
  (SELECT id FROM sales_intelligence.clients WHERE client_name = 'Mottivme - Sales' LIMIT 1),
  'Mottivme - Sales',
  ls.id,
  d.fonte_do_lead_bposs,
  fs.id,
  fs.stage_name,
  u.id,
  d.nome_usuario_responsavel,
  d.data_criada,
  COALESCE(d.data_e_hora_do_agendamento_bposs, d.scheduled_at),
  CASE WHEN d.status::TEXT = 'won' OR d.fluxo_vs ILIKE '%ganho%' THEN d.data_da_atualizacao END,
  CASE WHEN d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%' THEN d.data_da_atualizacao END,
  CASE
    WHEN d.status::TEXT = 'won' OR d.fluxo_vs ILIKE '%ganho%' THEN 'won'
    WHEN d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%' THEN 'lost'
    ELSE 'active'
  END,
  d.estado_onde_mora_contato,
  CASE
    WHEN (d.status::TEXT = 'lost' OR d.fluxo_vs ILIKE '%perdido%') AND d.motivo_do_perdido IS NULL
    THEN 'Não especificado'
    ELSE d.motivo_do_perdido
  END,
  CONCAT_WS(E'\n',
    CASE WHEN d.profissao_contato IS NOT NULL THEN 'Profissão: ' || d.profissao_contato END,
    CASE WHEN d.chat_channel IS NOT NULL THEN 'Canal: ' || d.chat_channel END
  ),
  CASE WHEN d.tag IS NOT NULL AND d.tag <> '' THEN ARRAY[d.tag]::TEXT[] END,
  COALESCE(d.data_da_atualizacao, d.data_criada, NOW())
FROM public.dashmottivmesales d
LEFT JOIN sales_intelligence.users u ON u.user_name = d.nome_usuario_responsavel
LEFT JOIN sales_intelligence.lead_sources ls ON ls.source_name = d.fonte_do_lead_bposs
LEFT JOIN sales_intelligence.funnel_stages fs ON fs.stage_name =
  CASE
    WHEN d.fluxo_vs ILIKE '%lead%' OR d.fluxo_vs ILIKE '%novo%' THEN 'Lead'
    WHEN d.fluxo_vs ILIKE '%contato%' OR d.fluxo_vs ILIKE '%agendado%' OR d.fluxo_vs::TEXT = 'booked' THEN 'Contato'
    WHEN d.fluxo_vs ILIKE '%qualificado%' THEN 'Qualificado'
    WHEN d.fluxo_vs ILIKE '%proposta%' THEN 'Proposta'
    WHEN d.fluxo_vs ILIKE '%negociação%' THEN 'Negociação'
    WHEN d.fluxo_vs ILIKE '%ganho%' OR d.fluxo_vs::TEXT = 'won' THEN 'Ganho'
    WHEN d.fluxo_vs ILIKE '%perdido%' OR d.fluxo_vs::TEXT = 'lost' THEN 'Perdido'
    ELSE 'Lead'
  END
WHERE d.id IS NOT NULL
ON CONFLICT (external_id) DO UPDATE SET
  lead_name = EXCLUDED.lead_name,
  updated_at = NOW();

SELECT
  '🎉 Migração completa!' as status,
  (SELECT COUNT(*) FROM public.dashmottivmesales) as total_original,
  (SELECT COUNT(*) FROM sales_intelligence.leads) as total_migrado;
