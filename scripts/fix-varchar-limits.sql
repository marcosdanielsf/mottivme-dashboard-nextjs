-- ============================================================================
-- FIX: Aumentar limites de VARCHAR
-- Alguns dados reais excedem os 50 caracteres
-- ============================================================================

-- Aumentar limites na tabela leads
ALTER TABLE sales_intelligence.leads
  ALTER COLUMN lead_phone TYPE VARCHAR(100),
  ALTER COLUMN source_name TYPE VARCHAR(255),
  ALTER COLUMN stage_name TYPE VARCHAR(255),
  ALTER COLUMN assigned_user_name TYPE VARCHAR(255),
  ALTER COLUMN scheduled_by_user_name TYPE VARCHAR(255),
  ALTER COLUMN lost_reason TYPE VARCHAR(500);

-- Aumentar limites na tabela lead_sources
ALTER TABLE sales_intelligence.lead_sources
  ALTER COLUMN source_name TYPE VARCHAR(255),
  ALTER COLUMN source_code TYPE VARCHAR(100);

-- Aumentar limites na tabela funnel_stages
ALTER TABLE sales_intelligence.funnel_stages
  ALTER COLUMN stage_name TYPE VARCHAR(255),
  ALTER COLUMN stage_code TYPE VARCHAR(100);

SELECT '✅ Limites de VARCHAR aumentados com sucesso!' as status;
