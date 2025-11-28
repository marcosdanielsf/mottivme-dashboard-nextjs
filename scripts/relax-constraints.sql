-- ============================================================================
-- RELAXAR CONSTRAINTS PARA DADOS REAIS
-- Remove constraints muito rígidas que impedem migração de dados reais
-- ============================================================================

-- 1. Remover constraint que exige won_value quando status = 'won'
-- Em dados reais, nem sempre temos o valor do negócio fechado
ALTER TABLE sales_intelligence.leads
DROP CONSTRAINT IF EXISTS check_won_value;

-- 2. Remover constraint que exige lost_reason quando status = 'lost'
-- Em dados reais, nem sempre temos o motivo da perda registrado
ALTER TABLE sales_intelligence.leads
DROP CONSTRAINT IF EXISTS check_lost_reason;

SELECT '✅ Constraints relaxadas com sucesso!' as status;
SELECT 'Agora você pode executar o script de migração sem erros.' as next_step;
