// Métricas do Dashboard Principal
export interface DashboardMetrics {
  // TRÁFEGO
  leads_traf: number;
  leads_qualif_traf: number;
  leads_agend_traf: number;
  leads_noshow_traf: number;
  calls_traf: number;
  leads_venda_traf: number;
  leads_desqualif_traf: number;
  pct_leads_qualif_traf: number;
  pct_qualif_agend_traf: number;
  pct_agend_calls_traf: number;
  pct_calls_venda_traf: number;
  // BPO/OTB
  prospec_otb: number;
  leads_otb: number;
  leads_qualif_otb: number;
  leads_agend_otb: number;
  leads_noshow_otb: number;
  calls_otb: number;
  leads_venda_otb: number;
  leads_desqualif_otb: number;
  pct_leads_qualif_otb: number;
  pct_qualif_agend_otb: number;
  pct_agend_calls_otb: number;
  pct_calls_venda_otb: number;
  // TOTAL
  leads_total: number;
  leads_qualif_total: number;
  leads_agend_total: number;
  calls_total: number;
  leads_venda_total: number;
  noshow_total: number;
  perdido_total: number;
  taxa_conv_total: number;
  pct_leads_qualif_total: number;
}

// Dados mensais para tabela
export interface MonthlyData {
  mes: string;
  inv_trafego: number;
  inv_bpo: number;
  sal: number;
  pct_agd: number;
  leads_agd: number;
  pct_calls: number;
  tt_calls: number;
  pct_ganhos: number;
  tt_ganhos: number;
  tl_agd_traf: number;
  tl_agd_bpo: number;
  calls_traf: number;
  calls_bpo: number;
  ganhos_traf: number;
  ganhos_bpo: number;
  cpl_traf: number;
  cpl_bpo: number;
  cpra_traf: number;
  cpra_bpo: number;
  cpa_traf: number;
  cpa_bpo: number;
}

// Dados de usuário para tabela
export interface UserData {
  user: string;
  inv_trafego: number;
  inv_bpo: number;
  sal: number;
  pct_agd: number;
  leads_agd: number;
  pct_calls: number;
  tt_calls: number;
  pct_ganhos: number;
  tt_ganhos: number;
  tl_agd_traf: number;
  tl_agd_bpo: number;
  calls_traf: number;
  calls_bpo: number;
  ganhos_traf: number;
  ganhos_bpo: number;
  cpl_traf: number;
  cpl_bpo: number;
  cpra_traf: number;
  cpra_bpo: number;
  cpa_traf: number;
  cpa_bpo: number;
}

// Ranking de Mottivados
export interface RankingMottivado {
  rank: number;
  nome: string;
  leads: number;
}

// Ranking de Clientes
export interface RankingCliente {
  rank: number;
  cliente: string;
  lead_qualif: number;
  tx_conv: string;
  leads_agend: number;
}

// Evolução mensal para gráficos
export interface EvolucaoData {
  month: string;
  lead_qualif: number;
  tx_conv: number;
  leads_agend: number;
  cpa_traf: number;
  cpa_bpo: number;
  otb: number;
  traf: number;
}

// ========================================
// NOVOS TIPOS PARA SUPABASE
// ========================================

// Métricas do Funil vindas do Supabase
export interface MetricasFunil {
  canal: string
  ano: number
  mes: number
  total_leads: number
  leads_novos: number
  leads_qualificando: number
  leads_qualificados: number
  leads_agendados: number
  leads_noshow: number
  leads_calls: number
  leads_ganhos: number
  leads_perdidos: number
  pct_qualificados: number
  pct_agendados: number
  pct_calls: number
  taxa_conversao: number
}

// Métricas por Usuário
export interface MetricasUsuario {
  usuario: string
  canal: string
  ano: number
  mes: number
  total_leads: number
  leads_qualificados: number
  leads_agendados: number
  leads_noshow: number
  leads_calls: number
  leads_ganhos: number
  leads_perdidos: number
  taxa_conversao: number
}

// Ranking Mottivados (do Supabase)
export interface RankingMottivadoSupabase {
  rank: number
  nome: string
  leads_qualificados: number
  leads_agendados: number
  leads_ganhos: number
}

// Ranking Clientes (do Supabase)
export interface RankingClienteSupabase {
  rank: number
  cliente: string
  leads_qualificados: number
  taxa_conversao: number
  leads_agendados: number
}

// Investimentos Mensais
export interface Investimento {
  ano: number
  mes: number
  investimento_trafego: number
  investimento_bpo: number
}
