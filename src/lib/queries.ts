import { supabase } from './supabase';

// Tipos de status na tabela
export type LeadStatus = 'booked' | 'qualifying' | 'no_show' | 'completed' | 'lost' | 'won';

// Interface do lead raw
export interface DashLead {
  id: string;
  contato_principal: string;
  lead_usuario_responsavel: string;
  data_criada: string;
  fonte_do_lead_bposs: string;
  funil: string;
  fluxo_vs: string;
  status: LeadStatus;
  data_que_o_lead_entrou_na_etapa_de_agendamento: string | null;
  data_e_hora_do_agendamento_bposs: string | null;
  motivo_do_perdido: string | null;
}

// Métricas calculadas do funil
export interface FunnelMetrics {
  // TRÁFEGO
  leads_traf: number;
  leads_qualif_traf: number;
  leads_agend_traf: number;
  leads_noshow_traf: number;
  calls_traf: number;
  leads_venda_traf: number;
  leads_desqualif_traf: number;
  // BPO
  prospec_otb: number;
  leads_otb: number;
  leads_qualif_otb: number;
  leads_agend_otb: number;
  leads_noshow_otb: number;
  calls_otb: number;
  leads_venda_otb: number;
  leads_desqualif_otb: number;
  // TOTAL
  leads_total: number;
  leads_qualif_total: number;
  leads_agend_total: number;
  calls_total: number;
  leads_venda_total: number;
  noshow_total: number;
  perdido_total: number;
}

// Detectar se é TRÁFEGO ou BPO
export function isTrafego(lead: DashLead): boolean {
  const fonte = lead.fonte_do_lead_bposs?.toLowerCase() || '';
  const funil = lead.funil?.toLowerCase() || '';
  
  return fonte.includes('tráfego') || 
         fonte.includes('trafego') ||
         fonte.includes('lead direct') ||
         funil.includes('tráfego') ||
         funil.includes('f2');
}

export function isBPO(lead: DashLead): boolean {
  const fonte = lead.fonte_do_lead_bposs?.toLowerCase() || '';
  const funil = lead.funil?.toLowerCase() || '';
  
  return fonte.includes('prospecção') ||
         fonte.includes('prospeccao') ||
         fonte.includes('bpo') ||
         funil.includes('bpo') ||
         funil.includes('f1');
}

// Detectar etapa do funil baseado em fluxo_vs e status
export function getEtapa(lead: DashLead): string {
  const fluxo = lead.fluxo_vs?.toLowerCase() || '';
  const status = lead.status?.toLowerCase() || '';
  
  // Mapeamento de etapas
  if (status === 'won') return 'ganho';
  if (status === 'lost') return 'perdido';
  if (status === 'no_show') return 'noshow';
  if (status === 'completed' || fluxo.includes('call') || fluxo.includes('reunião')) return 'call';
  if (status === 'booked' || fluxo.includes('agend')) return 'agendado';
  if (fluxo.includes('qualif') || fluxo.includes('sondagem')) return 'qualificado';
  
  return 'lead'; // default
}

// Buscar todos os leads
export async function fetchAllLeads(filters?: {
  startDate?: string;
  endDate?: string;
  usuario?: string;
}): Promise<DashLead[]> {
  let query = supabase
    .from('dashmottivmesales')
    .select('*');
  
  if (filters?.startDate) {
    query = query.gte('data_criada', filters.startDate);
  }
  if (filters?.endDate) {
    query = query.lte('data_criada', filters.endDate);
  }
  if (filters?.usuario) {
    query = query.eq('lead_usuario_responsavel', filters.usuario);
  }
  
  const { data, error } = await query;
  
  if (error) {
    console.error('Erro ao buscar leads:', error);
    return [];
  }
  
  return data || [];
}

// Calcular métricas do funil a partir dos leads
export function calculateFunnelMetrics(leads: DashLead[]): FunnelMetrics {
  const metrics: FunnelMetrics = {
    leads_traf: 0,
    leads_qualif_traf: 0,
    leads_agend_traf: 0,
    leads_noshow_traf: 0,
    calls_traf: 0,
    leads_venda_traf: 0,
    leads_desqualif_traf: 0,
    prospec_otb: 0,
    leads_otb: 0,
    leads_qualif_otb: 0,
    leads_agend_otb: 0,
    leads_noshow_otb: 0,
    calls_otb: 0,
    leads_venda_otb: 0,
    leads_desqualif_otb: 0,
    leads_total: 0,
    leads_qualif_total: 0,
    leads_agend_total: 0,
    calls_total: 0,
    leads_venda_total: 0,
    noshow_total: 0,
    perdido_total: 0,
  };

  leads.forEach(lead => {
    const etapa = getEtapa(lead);
    const trafego = isTrafego(lead);
    const bpo = isBPO(lead);

    // Contagem por canal
    if (trafego) {
      metrics.leads_traf++;
      if (['qualificado', 'agendado', 'call', 'ganho', 'perdido', 'noshow'].includes(etapa)) {
        metrics.leads_qualif_traf++;
      }
      if (['agendado', 'call', 'ganho', 'noshow'].includes(etapa)) {
        metrics.leads_agend_traf++;
      }
      if (etapa === 'noshow') metrics.leads_noshow_traf++;
      if (['call', 'ganho'].includes(etapa)) metrics.calls_traf++;
      if (etapa === 'ganho') metrics.leads_venda_traf++;
      if (etapa === 'perdido') metrics.leads_desqualif_traf++;
    }

    if (bpo) {
      metrics.prospec_otb++; // Prospecção = total BPO
      metrics.leads_otb++;
      if (['qualificado', 'agendado', 'call', 'ganho', 'perdido', 'noshow'].includes(etapa)) {
        metrics.leads_qualif_otb++;
      }
      if (['agendado', 'call', 'ganho', 'noshow'].includes(etapa)) {
        metrics.leads_agend_otb++;
      }
      if (etapa === 'noshow') metrics.leads_noshow_otb++;
      if (['call', 'ganho'].includes(etapa)) metrics.calls_otb++;
      if (etapa === 'ganho') metrics.leads_venda_otb++;
      if (etapa === 'perdido') metrics.leads_desqualif_otb++;
    }

    // Totais
    metrics.leads_total++;
    if (['qualificado', 'agendado', 'call', 'ganho', 'perdido', 'noshow'].includes(etapa)) {
      metrics.leads_qualif_total++;
    }
    if (['agendado', 'call', 'ganho', 'noshow'].includes(etapa)) {
      metrics.leads_agend_total++;
    }
    if (etapa === 'noshow') metrics.noshow_total++;
    if (['call', 'ganho'].includes(etapa)) metrics.calls_total++;
    if (etapa === 'ganho') metrics.leads_venda_total++;
    if (etapa === 'perdido') metrics.perdido_total++;
  });

  return metrics;
}

// Calcular percentuais
export function calculatePercentages(metrics: FunnelMetrics) {
  const safeDiv = (a: number, b: number) => b > 0 ? Math.round((a / b) * 100) : 0;
  
  return {
    // TRÁFEGO
    pct_leads_qualif_traf: safeDiv(metrics.leads_qualif_traf, metrics.leads_traf),
    pct_qualif_agend_traf: safeDiv(metrics.leads_agend_traf, metrics.leads_qualif_traf),
    pct_agend_calls_traf: safeDiv(metrics.calls_traf, metrics.leads_agend_traf),
    pct_calls_venda_traf: safeDiv(metrics.leads_venda_traf, metrics.calls_traf),
    pct_noshow_traf: safeDiv(metrics.leads_noshow_traf, metrics.leads_agend_traf),
    // BPO
    pct_leads_qualif_otb: safeDiv(metrics.leads_qualif_otb, metrics.leads_otb),
    pct_qualif_agend_otb: safeDiv(metrics.leads_agend_otb, metrics.leads_qualif_otb),
    pct_agend_calls_otb: safeDiv(metrics.calls_otb, metrics.leads_agend_otb),
    pct_calls_venda_otb: safeDiv(metrics.leads_venda_otb, metrics.calls_otb),
    pct_noshow_otb: safeDiv(metrics.leads_noshow_otb, metrics.leads_agend_otb),
    // TOTAL
    pct_leads_qualif_total: safeDiv(metrics.leads_qualif_total, metrics.leads_total),
    pct_qualif_agend_total: safeDiv(metrics.leads_agend_total, metrics.leads_qualif_total),
    pct_agend_calls_total: safeDiv(metrics.calls_total, metrics.leads_agend_total),
    pct_calls_venda_total: safeDiv(metrics.leads_venda_total, metrics.calls_total),
    pct_noshow_total: safeDiv(metrics.noshow_total, metrics.leads_agend_total),
    // Taxa de conversão geral
    taxa_conv_traf: safeDiv(metrics.leads_venda_traf, metrics.leads_traf) > 0 
      ? (metrics.leads_venda_traf / metrics.leads_traf * 100).toFixed(2) 
      : '0.00',
    taxa_conv_otb: safeDiv(metrics.leads_venda_otb, metrics.leads_otb) > 0 
      ? (metrics.leads_venda_otb / metrics.leads_otb * 100).toFixed(2) 
      : '0.00',
    taxa_conv_total: safeDiv(metrics.leads_venda_total, metrics.leads_total) > 0 
      ? (metrics.leads_venda_total / metrics.leads_total * 100).toFixed(2) 
      : '0.00',
  };
}

// Agrupar por usuário
export function groupByUsuario(leads: DashLead[]): Map<string, DashLead[]> {
  const groups = new Map<string, DashLead[]>();
  
  leads.forEach(lead => {
    const usuario = lead.lead_usuario_responsavel || 'Sem usuário';
    if (!groups.has(usuario)) {
      groups.set(usuario, []);
    }
    groups.get(usuario)!.push(lead);
  });
  
  return groups;
}

// Agrupar por mês
export function groupByMonth(leads: DashLead[]): Map<string, DashLead[]> {
  const groups = new Map<string, DashLead[]>();
  
  leads.forEach(lead => {
    if (!lead.data_criada) return;
    
    const date = new Date(lead.data_criada);
    const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
    const monthName = date.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
    
    if (!groups.has(monthKey)) {
      groups.set(monthKey, []);
    }
    groups.get(monthKey)!.push(lead);
  });
  
  return groups;
}

// Buscar lista de usuários únicos
export async function fetchUsuarios(): Promise<string[]> {
  const { data, error } = await supabase
    .from('dashmottivmesales')
    .select('lead_usuario_responsavel')
    .not('lead_usuario_responsavel', 'is', null);
  
  if (error) {
    console.error('Erro ao buscar usuários:', error);
    return [];
  }
  
  const usuarios = Array.from(new Set(data?.map(d => d.lead_usuario_responsavel).filter(Boolean)));
  return usuarios.sort();
}
