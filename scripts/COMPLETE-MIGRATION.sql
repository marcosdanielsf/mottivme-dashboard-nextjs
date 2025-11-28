-- ============================================================================
-- MIGRAÇÃO COMPLETA - SALES DASHBOARD
-- Este script faz TUDO: Limpar + Criar + Migrar
-- ============================================================================

DROP SCHEMA IF EXISTS sales_intelligence CASCADE;
DROP VIEW IF EXISTS public.sales_leads CASCADE;
DROP VIEW IF EXISTS public.sales_kpi_metrics CASCADE;
DROP VIEW IF EXISTS public.sales_ranking_users CASCADE;
DROP VIEW IF EXISTS public.sales_ranking_clients CASCADE;
DROP VIEW IF EXISTS public.sales_funnel_metrics CASCADE;
DROP VIEW IF EXISTS public.sales_evolution_daily CASCADE;
DROP VIEW IF EXISTS public.sales_source_performance CASCADE;

SELECT '🗑️ Schemas antigos removidos!' as status;

-- ============================================================================
-- SALES DASHBOARD - SCHEMA COMPLETO
-- Migração do Power BI "Mottivme Sales" para Supabase
-- Baseado em análise do arquivo .pbix
-- ============================================================================

-- ============================================================================
-- 1. CRIAR SCHEMA
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS sales_intelligence;

-- ============================================================================
-- 2. TABELAS DIMENSÃO (Lookup Tables)
-- ============================================================================

-- 2.1. Clientes
CREATE TABLE IF NOT EXISTS sales_intelligence.clients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação
  client_name VARCHAR(255) UNIQUE NOT NULL,
  client_code VARCHAR(50),

  -- Classificação
  industry VARCHAR(100), -- Tecnologia, Saúde, Educação, etc
  tier VARCHAR(50) CHECK (tier IN ('VIP', 'Premium', 'Standard', 'Basic')),

  -- Contato
  contact_email VARCHAR(255),
  contact_phone VARCHAR(50),

  -- Status
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Índices
  CONSTRAINT clients_name_not_empty CHECK (client_name <> '')
);

CREATE INDEX idx_clients_status ON sales_intelligence.clients(status);
CREATE INDEX idx_clients_tier ON sales_intelligence.clients(tier);

-- 2.2. Usuários/Vendedores
CREATE TABLE IF NOT EXISTS sales_intelligence.users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação
  user_name VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,

  -- Função
  role VARCHAR(50) CHECK (role IN ('SDR', 'Closer', 'Manager', 'Admin', 'BDR')),
  team VARCHAR(100), -- Time A, Time B, etc

  -- Status
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'on_leave')),

  -- Datas
  hired_at DATE,
  terminated_at DATE,

  -- Metas
  monthly_goal INTEGER, -- Meta mensal de vendas

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_role ON sales_intelligence.users(role);
CREATE INDEX idx_users_status ON sales_intelligence.users(status);
CREATE INDEX idx_users_team ON sales_intelligence.users(team);

-- 2.3. Etapas do Funil
CREATE TABLE IF NOT EXISTS sales_intelligence.funnel_stages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação
  stage_name VARCHAR(255) UNIQUE NOT NULL, -- Aumentado para 255
  stage_code VARCHAR(100), -- Aumentado para 100

  -- Ordenação e visualização
  stage_order INTEGER NOT NULL UNIQUE,
  color VARCHAR(20), -- HEX color para visualização
  icon VARCHAR(50),

  -- Descrição
  description TEXT,

  -- Configuração
  is_active BOOLEAN DEFAULT true,
  requires_contact BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_funnel_stages_order ON sales_intelligence.funnel_stages(stage_order);

-- 2.4. Fontes de Leads
CREATE TABLE IF NOT EXISTS sales_intelligence.lead_sources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação
  source_name VARCHAR(255) UNIQUE NOT NULL, -- Aumentado para 255
  source_code VARCHAR(100), -- Aumentado para 100

  -- Tipo
  source_type VARCHAR(50) CHECK (source_type IN ('Paid', 'Organic', 'Referral', 'Direct', 'Partner')),

  -- Custos (opcional)
  cost_per_lead DECIMAL(10,2),
  monthly_budget DECIMAL(10,2),

  -- Status
  active BOOLEAN DEFAULT true,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lead_sources_active ON sales_intelligence.lead_sources(active);
CREATE INDEX idx_lead_sources_type ON sales_intelligence.lead_sources(source_type);

-- 2.5. Calendário (Dimensão Tempo)
CREATE TABLE IF NOT EXISTS sales_intelligence.calendar (
  date DATE PRIMARY KEY,

  -- Ano
  year INTEGER NOT NULL,
  year_name VARCHAR(10), -- "2025"

  -- Quarter
  quarter INTEGER CHECK (quarter BETWEEN 1 AND 4),
  quarter_name VARCHAR(10), -- "Q1 2025"

  -- Mês
  month INTEGER CHECK (month BETWEEN 1 AND 12),
  month_name VARCHAR(20), -- "Janeiro", "Fevereiro"
  month_short VARCHAR(3), -- "Jan", "Fev"

  -- Semana
  week INTEGER CHECK (week BETWEEN 1 AND 53),
  week_of_month INTEGER CHECK (week_of_month BETWEEN 1 AND 6),

  -- Dia
  day_of_month INTEGER CHECK (day_of_month BETWEEN 1 AND 31),
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Domingo
  day_name VARCHAR(20), -- "Segunda-feira"
  day_short VARCHAR(3), -- "Seg"

  -- Flags
  is_weekend BOOLEAN DEFAULT false,
  is_holiday BOOLEAN DEFAULT false,
  is_business_day BOOLEAN DEFAULT true,
  holiday_name VARCHAR(100)
);

CREATE INDEX idx_calendar_year_month ON sales_intelligence.calendar(year, month);
CREATE INDEX idx_calendar_is_business_day ON sales_intelligence.calendar(is_business_day);

-- ============================================================================
-- 3. TABELAS FATO (Transacionais)
-- ============================================================================

-- 3.1. Leads (Principal)
CREATE TABLE IF NOT EXISTS sales_intelligence.leads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação
  external_id VARCHAR(255) UNIQUE, -- ID do CRM original
  lead_name VARCHAR(255) NOT NULL,
  lead_email VARCHAR(255),
  lead_phone VARCHAR(100), -- Aumentado para 100 (dados reais podem ter múltiplos números)
  lead_company VARCHAR(255),

  -- Relações com dimensões
  client_id UUID REFERENCES sales_intelligence.clients(id),
  client_name VARCHAR(255), -- Desnormalizado para performance

  source_id UUID REFERENCES sales_intelligence.lead_sources(id),
  source_name VARCHAR(255), -- Desnormalizado (aumentado para 255)

  stage_id UUID REFERENCES sales_intelligence.funnel_stages(id),
  stage_name VARCHAR(255), -- Desnormalizado (aumentado para 255)

  -- Atribuição
  assigned_user_id UUID REFERENCES sales_intelligence.users(id),
  assigned_user_name VARCHAR(255), -- Desnormalizado

  scheduled_by_user_id UUID REFERENCES sales_intelligence.users(id),
  scheduled_by_user_name VARCHAR(255), -- Desnormalizado

  -- Datas importantes (tracking do funil)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  contacted_at TIMESTAMPTZ, -- Primeiro contato
  qualified_at TIMESTAMPTZ, -- Lead qualificado
  proposal_sent_at TIMESTAMPTZ, -- Proposta enviada
  won_at TIMESTAMPTZ, -- Ganho
  lost_at TIMESTAMPTZ, -- Perdido

  -- Valores
  estimated_value DECIMAL(10,2), -- Valor estimado
  won_value DECIMAL(10,2), -- Valor real ganho

  -- Status e classificação
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'won', 'lost', 'archived', 'spam')),
  priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

  -- Localização
  country VARCHAR(3) DEFAULT 'USA', -- USA, BRA, MEX, etc
  state VARCHAR(255), -- Aumentado para 255
  city VARCHAR(255), -- Aumentado para 255

  -- Métricas calculadas (atualizadas por triggers)
  days_in_funnel INTEGER,
  days_to_contact INTEGER,
  days_to_qualify INTEGER,
  days_to_close INTEGER,
  conversion_probability DECIMAL(5,2), -- 0-100%

  -- Motivo de perda
  lost_reason VARCHAR(500), -- Aumentado para 500 (motivos podem ser longos)
  lost_notes TEXT,

  -- Observações
  notes TEXT,
  tags VARCHAR(255)[], -- Array de tags

  -- Metadata
  updated_at TIMESTAMPTZ DEFAULT NOW()

  -- Nota: Constraints relaxadas para permitir migração de dados reais
  -- Em produção, nem sempre temos won_value ou lost_reason preenchidos
);

-- Índices para performance
CREATE INDEX idx_leads_client_id ON sales_intelligence.leads(client_id);
CREATE INDEX idx_leads_source_id ON sales_intelligence.leads(source_id);
CREATE INDEX idx_leads_stage_id ON sales_intelligence.leads(stage_id);
CREATE INDEX idx_leads_assigned_user_id ON sales_intelligence.leads(assigned_user_id);
CREATE INDEX idx_leads_status ON sales_intelligence.leads(status);
CREATE INDEX idx_leads_created_at ON sales_intelligence.leads(created_at DESC);
CREATE INDEX idx_leads_won_at ON sales_intelligence.leads(won_at DESC) WHERE won_at IS NOT NULL;
CREATE INDEX idx_leads_client_status ON sales_intelligence.leads(client_id, status);

-- 3.2. Investimentos (BPO/Marketing)
CREATE TABLE IF NOT EXISTS sales_intelligence.investments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Relação
  client_id UUID REFERENCES sales_intelligence.clients(id),
  client_name VARCHAR(255),

  -- Tipo de investimento
  investment_type VARCHAR(100) NOT NULL, -- BPO, Facebook Ads, Google Ads, etc
  category VARCHAR(50), -- Marketing, Operations, Training

  -- Valores
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',

  -- Período
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,

  -- Status
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),

  -- Metadata
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  CONSTRAINT check_period CHECK (period_end >= period_start),
  CONSTRAINT check_amount_positive CHECK (amount > 0)
);

CREATE INDEX idx_investments_client_id ON sales_intelligence.investments(client_id);
CREATE INDEX idx_investments_period ON sales_intelligence.investments(period_start, period_end);

-- ============================================================================
-- 4. POPULAR DADOS INICIAIS
-- ============================================================================

-- 4.1. Popular Calendário (2020-2030)
INSERT INTO sales_intelligence.calendar (
  date, year, year_name, quarter, quarter_name,
  month, month_name, month_short,
  week, day_of_month, day_of_week,
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
ON CONFLICT (date) DO NOTHING;

-- Atualizar is_business_day
UPDATE sales_intelligence.calendar
SET is_business_day = NOT is_weekend;

-- 4.2. Popular Etapas do Funil
INSERT INTO sales_intelligence.funnel_stages (stage_name, stage_code, stage_order, color, description) VALUES
  ('Lead', 'LEAD', 1, '#3B82F6', 'Lead novo, ainda não contactado'),
  ('Contato', 'CONTACT', 2, '#8B5CF6', 'Primeiro contato realizado'),
  ('Qualificado', 'QUALIFIED', 3, '#EC4899', 'Lead qualificado, demonstrou interesse'),
  ('Proposta', 'PROPOSAL', 4, '#F59E0B', 'Proposta comercial enviada'),
  ('Negociação', 'NEGOTIATION', 5, '#F97316', 'Em processo de negociação'),
  ('Ganho', 'WON', 6, '#10B981', 'Venda fechada com sucesso'),
  ('Perdido', 'LOST', 7, '#EF4444', 'Oportunidade perdida')
ON CONFLICT (stage_name) DO NOTHING;

-- 4.3. Popular Fontes de Leads (Exemplos)
INSERT INTO sales_intelligence.lead_sources (source_name, source_code, source_type, cost_per_lead) VALUES
  ('Facebook Ads', 'FB_ADS', 'Paid', 15.00),
  ('Google Ads', 'GOOGLE_ADS', 'Paid', 25.00),
  ('LinkedIn Ads', 'LINKEDIN_ADS', 'Paid', 45.00),
  ('Instagram', 'INSTAGRAM', 'Organic', 0.00),
  ('Indicação', 'REFERRAL', 'Referral', 0.00),
  ('Website', 'WEBSITE', 'Organic', 0.00),
  ('Parceiro', 'PARTNER', 'Partner', 10.00),
  ('Busca Orgânica', 'ORGANIC_SEARCH', 'Organic', 0.00),
  ('Email Marketing', 'EMAIL', 'Paid', 5.00),
  ('Eventos', 'EVENT', 'Direct', 50.00)
ON CONFLICT (source_name) DO NOTHING;

-- ============================================================================
-- 5. FUNCTIONS E TRIGGERS
-- ============================================================================

-- 5.1. Função para atualizar métricas de tempo do lead
CREATE OR REPLACE FUNCTION sales_intelligence.update_lead_metrics()
RETURNS TRIGGER AS $$
BEGIN
  -- Calcular days_in_funnel
  NEW.days_in_funnel = EXTRACT(DAY FROM (NOW() - NEW.created_at))::INTEGER;

  -- Calcular days_to_contact
  IF NEW.contacted_at IS NOT NULL AND OLD.contacted_at IS NULL THEN
    NEW.days_to_contact = EXTRACT(DAY FROM (NEW.contacted_at - NEW.created_at))::INTEGER;
  END IF;

  -- Calcular days_to_qualify
  IF NEW.qualified_at IS NOT NULL AND OLD.qualified_at IS NULL THEN
    NEW.days_to_qualify = EXTRACT(DAY FROM (NEW.qualified_at - NEW.created_at))::INTEGER;
  END IF;

  -- Calcular days_to_close
  IF NEW.won_at IS NOT NULL AND OLD.won_at IS NULL THEN
    NEW.days_to_close = EXTRACT(DAY FROM (NEW.won_at - NEW.created_at))::INTEGER;
  END IF;

  -- Atualizar updated_at
  NEW.updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lead_metrics_trigger
BEFORE UPDATE ON sales_intelligence.leads
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_lead_metrics();

-- 5.2. Função para atualizar updated_at
CREATE OR REPLACE FUNCTION sales_intelligence.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_clients_updated_at
BEFORE UPDATE ON sales_intelligence.clients
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_updated_at();

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON sales_intelligence.users
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_updated_at();

CREATE TRIGGER update_lead_sources_updated_at
BEFORE UPDATE ON sales_intelligence.lead_sources
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_updated_at();

CREATE TRIGGER update_investments_updated_at
BEFORE UPDATE ON sales_intelligence.investments
FOR EACH ROW
EXECUTE FUNCTION sales_intelligence.update_updated_at();

-- ============================================================================
-- 6. VIEWS DE MÉTRICAS (substituem DAX Measures do Power BI)
-- ============================================================================

-- 6.1. KPIs Principais
CREATE OR REPLACE VIEW sales_intelligence.kpi_metrics AS
SELECT
  -- Total de Leads
  COUNT(*) as total_leads,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as leads_today,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as leads_7d,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as leads_30d,
  COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)) as leads_month,

  -- Status
  COUNT(*) FILTER (WHERE status = 'active') as active_leads,
  COUNT(*) FILTER (WHERE status = 'won') as total_won,
  COUNT(*) FILTER (WHERE status = 'lost') as total_lost,

  -- Conversão
  ROUND((COUNT(*) FILTER (WHERE status = 'won')::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 2) as conversion_rate,
  ROUND((COUNT(*) FILTER (WHERE status = 'won' AND won_at >= DATE_TRUNC('month', CURRENT_DATE))::NUMERIC /
    NULLIF(COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)), 0)) * 100, 2) as conversion_rate_month,

  -- Valores
  SUM(won_value) as total_revenue,
  SUM(won_value) FILTER (WHERE won_at >= CURRENT_DATE) as revenue_today,
  SUM(won_value) FILTER (WHERE won_at >= DATE_TRUNC('month', CURRENT_DATE)) as revenue_month,
  ROUND(AVG(won_value), 2) as avg_ticket,
  ROUND(AVG(won_value) FILTER (WHERE won_at >= DATE_TRUNC('month', CURRENT_DATE)), 2) as avg_ticket_month,

  -- Tempo médio
  ROUND(AVG(days_to_contact) FILTER (WHERE contacted_at IS NOT NULL), 1) as avg_days_to_contact,
  ROUND(AVG(days_to_qualify) FILTER (WHERE qualified_at IS NOT NULL), 1) as avg_days_to_qualify,
  ROUND(AVG(days_to_close) FILTER (WHERE status = 'won'), 1) as avg_days_to_close,
  ROUND(AVG(days_in_funnel) FILTER (WHERE status = 'active'), 1) as avg_days_in_funnel_active,

  -- Por etapa (funil)
  COUNT(*) FILTER (WHERE stage_name = 'Lead') as stage_lead,
  COUNT(*) FILTER (WHERE stage_name = 'Contato') as stage_contact,
  COUNT(*) FILTER (WHERE stage_name = 'Qualificado') as stage_qualified,
  COUNT(*) FILTER (WHERE stage_name = 'Proposta') as stage_proposal,
  COUNT(*) FILTER (WHERE stage_name = 'Negociação') as stage_negotiation,
  COUNT(*) FILTER (WHERE stage_name = 'Ganho') as stage_won,
  COUNT(*) FILTER (WHERE stage_name = 'Perdido') as stage_lost
FROM sales_intelligence.leads;

-- 6.2. Ranking de Colaboradores
CREATE OR REPLACE VIEW sales_intelligence.ranking_users AS
SELECT
  u.id,
  u.user_name,
  u.email,
  u.role,
  u.team,
  u.status,

  -- Contadores
  COUNT(l.id) as total_leads,
  COUNT(l.id) FILTER (WHERE l.status = 'active') as active_leads,
  COUNT(l.id) FILTER (WHERE l.status = 'won') as total_won,
  COUNT(l.id) FILTER (WHERE l.status = 'lost') as total_lost,

  -- Valores
  COALESCE(SUM(l.won_value), 0) as total_revenue,
  ROUND(AVG(l.won_value), 2) as avg_ticket,

  -- Performance
  ROUND((COUNT(l.id) FILTER (WHERE l.status = 'won')::NUMERIC / NULLIF(COUNT(l.id), 0)) * 100, 2) as conversion_rate,
  ROUND(AVG(l.days_to_close) FILTER (WHERE l.status = 'won'), 1) as avg_days_to_close,
  ROUND(AVG(l.days_to_contact) FILTER (WHERE l.contacted_at IS NOT NULL), 1) as avg_days_to_contact,

  -- Este mês
  COUNT(l.id) FILTER (WHERE l.created_at >= DATE_TRUNC('month', CURRENT_DATE)) as leads_this_month,
  COUNT(l.id) FILTER (WHERE l.won_at >= DATE_TRUNC('month', CURRENT_DATE)) as won_this_month,
  COALESCE(SUM(l.won_value) FILTER (WHERE l.won_at >= DATE_TRUNC('month', CURRENT_DATE)), 0) as revenue_this_month

FROM sales_intelligence.users u
LEFT JOIN sales_intelligence.leads l ON l.assigned_user_id = u.id
WHERE u.status = 'active'
GROUP BY u.id, u.user_name, u.email, u.role, u.team, u.status
ORDER BY total_revenue DESC;

-- 6.3. Ranking de Clientes
CREATE OR REPLACE VIEW sales_intelligence.ranking_clients AS
SELECT
  c.id,
  c.client_name,
  c.industry,
  c.tier,
  c.status,

  -- Contadores
  COUNT(l.id) as total_leads,
  COUNT(l.id) FILTER (WHERE l.status = 'active') as active_leads,
  COUNT(l.id) FILTER (WHERE l.status = 'won') as total_won,
  COUNT(l.id) FILTER (WHERE l.status = 'lost') as total_lost,

  -- Valores
  COALESCE(SUM(l.won_value), 0) as total_revenue,
  ROUND(AVG(l.won_value) FILTER (WHERE l.status = 'won'), 2) as avg_ticket,

  -- Performance
  ROUND((COUNT(l.id) FILTER (WHERE l.status = 'won')::NUMERIC / NULLIF(COUNT(l.id), 0)) * 100, 2) as conversion_rate,
  ROUND(AVG(l.days_to_close) FILTER (WHERE l.status = 'won'), 1) as avg_days_to_close,

  -- Investimentos
  COALESCE(SUM(i.amount), 0) as total_investment,

  -- ROI
  ROUND((COALESCE(SUM(l.won_value), 0) / NULLIF(COALESCE(SUM(i.amount), 0), 0)) * 100, 2) as roi_percentage,

  -- Este mês
  COUNT(l.id) FILTER (WHERE l.created_at >= DATE_TRUNC('month', CURRENT_DATE)) as leads_this_month,
  COALESCE(SUM(l.won_value) FILTER (WHERE l.won_at >= DATE_TRUNC('month', CURRENT_DATE)), 0) as revenue_this_month

FROM sales_intelligence.clients c
LEFT JOIN sales_intelligence.leads l ON l.client_id = c.id
LEFT JOIN sales_intelligence.investments i ON i.client_id = c.id
WHERE c.status = 'active'
GROUP BY c.id, c.client_name, c.industry, c.tier, c.status
ORDER BY total_revenue DESC;

-- 6.4. Funil de Vendas (Visual)
CREATE OR REPLACE VIEW sales_intelligence.funnel_metrics AS
SELECT
  fs.id,
  fs.stage_name,
  fs.stage_code,
  fs.stage_order,
  fs.color,

  -- Contadores
  COUNT(l.id) as count,
  COALESCE(SUM(l.estimated_value), 0) as total_estimated_value,
  COALESCE(SUM(l.won_value), 0) as total_won_value,

  -- Percentuais
  ROUND((COUNT(l.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM sales_intelligence.leads), 0)) * 100, 2) as percentage,

  -- Conversão para próxima etapa (NULL para última etapa)
  CASE
    WHEN fs.stage_order < (SELECT MAX(stage_order) FROM sales_intelligence.funnel_stages) THEN
      ROUND((
        (SELECT COUNT(*) FROM sales_intelligence.leads l2
         INNER JOIN sales_intelligence.funnel_stages fs2 ON l2.stage_id = fs2.id
         WHERE fs2.stage_order > fs.stage_order)::NUMERIC
        / NULLIF(COUNT(l.id), 0)
      ) * 100, 2)
    ELSE NULL
  END as conversion_to_next

FROM sales_intelligence.funnel_stages fs
LEFT JOIN sales_intelligence.leads l ON l.stage_id = fs.id
GROUP BY fs.id, fs.stage_name, fs.stage_code, fs.stage_order, fs.color
ORDER BY fs.stage_order;

-- 6.5. Evolução Temporal (Diária)
CREATE OR REPLACE VIEW sales_intelligence.evolution_daily AS
SELECT
  c.date,
  c.day_name,
  c.is_weekend,

  -- Leads criados
  COUNT(l.id) as leads_created,
  COALESCE(SUM(l.estimated_value), 0) as estimated_value,

  -- Leads contactados
  COUNT(l.id) FILTER (WHERE DATE(l.contacted_at) = c.date) as leads_contacted,

  -- Leads ganhos
  COUNT(l.id) FILTER (WHERE DATE(l.won_at) = c.date) as leads_won,
  COALESCE(SUM(l.won_value) FILTER (WHERE DATE(l.won_at) = c.date), 0) as revenue,

  -- Leads perdidos
  COUNT(l.id) FILTER (WHERE DATE(l.lost_at) = c.date) as leads_lost

FROM sales_intelligence.calendar c
LEFT JOIN sales_intelligence.leads l ON DATE(l.created_at) = c.date
WHERE c.date >= CURRENT_DATE - INTERVAL '90 days'
  AND c.date <= CURRENT_DATE
GROUP BY c.date, c.day_name, c.is_weekend
ORDER BY c.date DESC;

-- 6.6. Performance por Fonte
CREATE OR REPLACE VIEW sales_intelligence.source_performance AS
SELECT
  ls.id,
  ls.source_name,
  ls.source_type,
  ls.cost_per_lead,

  -- Contadores
  COUNT(l.id) as total_leads,
  COUNT(l.id) FILTER (WHERE l.status = 'won') as total_won,

  -- Valores
  COALESCE(SUM(l.won_value), 0) as total_revenue,

  -- Performance
  ROUND((COUNT(l.id) FILTER (WHERE l.status = 'won')::NUMERIC / NULLIF(COUNT(l.id), 0)) * 100, 2) as conversion_rate,

  -- ROI
  (COUNT(l.id) * ls.cost_per_lead) as total_cost,
  ROUND((COALESCE(SUM(l.won_value), 0) / NULLIF((COUNT(l.id) * ls.cost_per_lead), 0)) * 100, 2) as roi_percentage,

  -- Este mês
  COUNT(l.id) FILTER (WHERE l.created_at >= DATE_TRUNC('month', CURRENT_DATE)) as leads_this_month

FROM sales_intelligence.lead_sources ls
LEFT JOIN sales_intelligence.leads l ON l.source_id = ls.id
WHERE ls.active = true
GROUP BY ls.id, ls.source_name, ls.source_type, ls.cost_per_lead
ORDER BY total_revenue DESC;

-- ============================================================================
-- 7. VIEWS NO SCHEMA PUBLIC (para acesso via REST API)
-- ============================================================================

CREATE OR REPLACE VIEW public.sales_leads AS
SELECT * FROM sales_intelligence.leads;

CREATE OR REPLACE VIEW public.sales_kpi_metrics AS
SELECT * FROM sales_intelligence.kpi_metrics;

CREATE OR REPLACE VIEW public.sales_ranking_users AS
SELECT * FROM sales_intelligence.ranking_users;

CREATE OR REPLACE VIEW public.sales_ranking_clients AS
SELECT * FROM sales_intelligence.ranking_clients;

CREATE OR REPLACE VIEW public.sales_funnel_metrics AS
SELECT * FROM sales_intelligence.funnel_metrics;

CREATE OR REPLACE VIEW public.sales_evolution_daily AS
SELECT * FROM sales_intelligence.evolution_daily;

CREATE OR REPLACE VIEW public.sales_source_performance AS
SELECT * FROM sales_intelligence.source_performance;

-- ============================================================================
-- 8. PERMISSÕES
-- ============================================================================

GRANT USAGE ON SCHEMA sales_intelligence TO anon, authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sales_intelligence TO anon, authenticated, service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA sales_intelligence TO anon, authenticated, service_role;

GRANT SELECT ON public.sales_leads TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_kpi_metrics TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_ranking_users TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_ranking_clients TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_funnel_metrics TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_evolution_daily TO anon, authenticated, service_role;
GRANT SELECT ON public.sales_source_performance TO anon, authenticated, service_role;

-- ============================================================================
-- 9. VERIFICAÇÃO
-- ============================================================================

SELECT 'Sales Dashboard Schema criado com sucesso!' as status;

-- Verificar tabelas criadas
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'sales_intelligence'
ORDER BY table_name;

-- Verificar views criadas
SELECT table_name
FROM information_schema.views
WHERE table_schema IN ('sales_intelligence', 'public')
  AND table_name LIKE 'sales_%'
ORDER BY table_name;

-- Verificar dados populados
SELECT
  (SELECT COUNT(*) FROM sales_intelligence.calendar) as total_calendar_days,
  (SELECT COUNT(*) FROM sales_intelligence.funnel_stages) as total_funnel_stages,
  (SELECT COUNT(*) FROM sales_intelligence.lead_sources) as total_lead_sources;

-- ============================================================================
-- MIGRAÇÃO DE DADOS
-- ============================================================================

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
