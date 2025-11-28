import { supabase } from './supabase'

// Tipos
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

export interface RankingMottivado {
  rank: number
  nome: string
  leads_qualificados: number
  leads_agendados: number
  leads_ganhos: number
}

export interface RankingCliente {
  rank: number
  cliente: string
  leads_qualificados: number
  taxa_conversao: number
  leads_agendados: number
}

export interface Investimento {
  ano: number
  mes: number
  investimento_trafego: number
  investimento_bpo: number
}

export interface TotaisCanal {
  total_leads: number
  leads_qualificados: number
  leads_agendados: number
  leads_noshow: number
  leads_calls: number
  leads_ganhos: number
  leads_perdidos: number
}

// Queries

// Buscar métricas do funil (para HOME)
export async function getMetricasFunil(ano?: number, mes?: number) {
  let query = supabase
    .from('vw_metricas_funil')
    .select('*')

  if (ano) query = query.eq('ano', ano)
  if (mes) query = query.eq('mes', mes)

  const { data, error } = await query.order('ano', { ascending: false }).order('mes', { ascending: false })

  if (error) {
    console.error('Erro ao buscar métricas funil:', error)
    return []
  }
  return data as MetricasFunil[]
}

// Buscar métricas por usuário (para USUÁRIOS)
export async function getMetricasUsuario(ano?: number, mes?: number) {
  let query = supabase
    .from('vw_metricas_usuario')
    .select('*')

  if (ano) query = query.eq('ano', ano)
  if (mes) query = query.eq('mes', mes)

  const { data, error } = await query.order('leads_ganhos', { ascending: false })

  if (error) {
    console.error('Erro ao buscar métricas usuário:', error)
    return []
  }
  return data as MetricasUsuario[]
}

// Buscar ranking de Mottivados
export async function getRankingMottivados() {
  const { data, error } = await supabase
    .from('vw_ranking_mottivados')
    .select('*')
    .order('rank', { ascending: true })
    .limit(20)

  if (error) {
    console.error('Erro ao buscar ranking mottivados:', error)
    return []
  }
  return data as RankingMottivado[]
}

// Buscar ranking de Clientes
export async function getRankingClientes() {
  const { data, error } = await supabase
    .from('vw_ranking_clientes')
    .select('*')
    .order('rank', { ascending: true })
    .limit(20)

  if (error) {
    console.error('Erro ao buscar ranking clientes:', error)
    return []
  }
  return data as RankingCliente[]
}

// Buscar investimentos mensais
export async function getInvestimentos(ano?: number) {
  let query = supabase
    .from('investimentos_mensais')
    .select('*')

  if (ano) query = query.eq('ano', ano)

  const { data, error } = await query.order('ano', { ascending: false }).order('mes', { ascending: false })

  if (error) {
    console.error('Erro ao buscar investimentos:', error)
    return []
  }
  return data as Investimento[]
}

// Buscar evolução mensal (para gráficos)
export async function getEvolucaoMensal(ano: number) {
  const { data, error } = await supabase
    .from('vw_metricas_funil')
    .select('*')
    .eq('ano', ano)
    .order('mes', { ascending: true })

  if (error) {
    console.error('Erro ao buscar evolução:', error)
    return []
  }
  return data as MetricasFunil[]
}

// Buscar totais consolidados do funil atual
export async function getTotaisFunil() {
  const { data, error } = await supabase
    .from('vw_metricas_funil')
    .select('*')

  if (error) {
    console.error('Erro ao buscar totais:', error)
    return null
  }

  // Consolidar por canal
  const trafego = data?.filter((d: MetricasFunil) => d.canal === 'TRAFEGO').reduce((acc: TotaisCanal, curr) => ({
    total_leads: acc.total_leads + curr.total_leads,
    leads_qualificados: acc.leads_qualificados + curr.leads_qualificados,
    leads_agendados: acc.leads_agendados + curr.leads_agendados,
    leads_noshow: acc.leads_noshow + curr.leads_noshow,
    leads_calls: acc.leads_calls + curr.leads_calls,
    leads_ganhos: acc.leads_ganhos + curr.leads_ganhos,
    leads_perdidos: acc.leads_perdidos + curr.leads_perdidos,
  }), { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 })

  const bpo = data?.filter((d: MetricasFunil) => d.canal === 'BPO').reduce((acc: TotaisCanal, curr) => ({
    total_leads: acc.total_leads + curr.total_leads,
    leads_qualificados: acc.leads_qualificados + curr.leads_qualificados,
    leads_agendados: acc.leads_agendados + curr.leads_agendados,
    leads_noshow: acc.leads_noshow + curr.leads_noshow,
    leads_calls: acc.leads_calls + curr.leads_calls,
    leads_ganhos: acc.leads_ganhos + curr.leads_ganhos,
    leads_perdidos: acc.leads_perdidos + curr.leads_perdidos,
  }), { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 })

  return { trafego, bpo }
}
