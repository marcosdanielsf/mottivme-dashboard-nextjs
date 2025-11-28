'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { 
  fetchAllLeads, 
  calculateFunnelMetrics, 
  calculatePercentages,
  groupByMonth,
  type DashLead,
  type FunnelMetrics
} from '@/lib/queries';

interface MonthlyRow {
  mes: string;
  leads_traf: number;
  leads_bpo: number;
  leads_total: number;
  qualif_traf: number;
  qualif_bpo: number;
  agend_traf: number;
  agend_bpo: number;
  calls_traf: number;
  calls_bpo: number;
  ganhos_traf: number;
  ganhos_bpo: number;
}

export default function HomePage() {
  const [metrics, setMetrics] = useState<FunnelMetrics | null>(null);
  const [percentages, setPercentages] = useState<ReturnType<typeof calculatePercentages> | null>(null);
  const [monthlyData, setMonthlyData] = useState<MonthlyRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Buscar todos os leads
      const leads = await fetchAllLeads();
      
      if (leads.length === 0) {
        setError('Nenhum lead encontrado na tabela dashmottivmesales');
        setLoading(false);
        return;
      }
      
      // Calcular métricas do funil
      const funnelMetrics = calculateFunnelMetrics(leads);
      const pcts = calculatePercentages(funnelMetrics);
      
      setMetrics(funnelMetrics);
      setPercentages(pcts);
      
      // Agrupar por mês para tabela
      const byMonth = groupByMonth(leads);
      const monthRows: MonthlyRow[] = [];
      
      // Ordenar meses
      const sortedMonths = [...byMonth.keys()].sort();
      
      sortedMonths.forEach(monthKey => {
        const monthLeads = byMonth.get(monthKey)!;
        const monthMetrics = calculateFunnelMetrics(monthLeads);
        
        const date = new Date(monthKey + '-01');
        const mesNome = date.toLocaleDateString('pt-BR', { month: 'long' });
        const mesCapitalized = mesNome.charAt(0).toUpperCase() + mesNome.slice(1);
        
        monthRows.push({
          mes: mesCapitalized,
          leads_traf: monthMetrics.leads_traf,
          leads_bpo: monthMetrics.leads_otb,
          leads_total: monthMetrics.leads_total,
          qualif_traf: monthMetrics.leads_qualif_traf,
          qualif_bpo: monthMetrics.leads_qualif_otb,
          agend_traf: monthMetrics.leads_agend_traf,
          agend_bpo: monthMetrics.leads_agend_otb,
          calls_traf: monthMetrics.calls_traf,
          calls_bpo: monthMetrics.calls_otb,
          ganhos_traf: monthMetrics.leads_venda_traf,
          ganhos_bpo: monthMetrics.leads_venda_otb,
        });
      });
      
      setMonthlyData(monthRows);
      
    } catch (err) {
      console.error('Erro ao carregar dados:', err);
      setError('Erro ao conectar com Supabase. Verifique as credenciais.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <div className="text-cyan-400 text-xl">Carregando dados do Supabase...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <div className="text-center">
          <div className="text-red-400 text-xl mb-4">{error}</div>
          <button 
            onClick={loadData}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Tentar novamente
          </button>
        </div>
      </div>
    );
  }

  if (!metrics || !percentages) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <div className="text-gray-400 text-xl">Sem dados para exibir</div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />

      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          {/* Title */}
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-light">
              <span className="text-white">Overview</span>{' '}
              <span className="text-cyan-400">Comercial</span>
            </h1>
            <button 
              onClick={loadData}
              className="bg-blue-600/20 border border-blue-500 text-blue-400 px-4 py-2 rounded-lg text-sm hover:bg-blue-600/30"
            >
              🔄 Atualizar
            </button>
          </div>

          {/* FUNIL DE MÉTRICAS - TRÁFEGO / BPO / TOTAL */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            {/* HEADER ROW */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 text-center text-xs text-gray-400 mb-3">
              <div></div>
              <div>Prospec</div>
              <div>Lead</div>
              <div>%</div>
              <div>Qualif</div>
              <div>%</div>
              <div>Agend</div>
              <div>%</div>
              <div>NoShow</div>
              <div>%</div>
              <div>Calls</div>
              <div>%</div>
              <div>Ganho</div>
              <div>%</div>
              <div>Perdido</div>
              <div>Tx Conv</div>
            </div>

            {/* TRÁFEGO Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1">
                <span className="text-cyan-400 font-semibold text-sm">TRÁFEGO</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="text-center text-gray-500">—</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_traf.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_leads_qualif_traf}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_traf.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_qualif_agend_traf}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_traf}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_agend_calls_traf}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_noshow_traf}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_noshow_traf}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_traf}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_calls_venda_traf}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_traf}</div>
              <div className="text-center text-gray-300 text-sm">—</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_desqualif_traf}</div>
              <div className={`rounded px-2 py-1 text-center font-bold text-sm ${
                parseFloat(percentages.taxa_conv_traf) >= 5 
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>{percentages.taxa_conv_traf}%</div>
            </div>

            {/* BPO Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1">
                <span className="text-cyan-400 font-semibold text-sm">BPO</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.prospec_otb.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_otb.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_leads_qualif_otb}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_otb.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_qualif_agend_otb}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_otb}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_agend_calls_otb}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_noshow_otb}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_noshow_otb}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_otb}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_calls_venda_otb}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_otb}</div>
              <div className="text-center text-gray-300 text-sm">—</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_desqualif_otb}</div>
              <div className={`rounded px-2 py-1 text-center font-bold text-sm ${
                parseFloat(percentages.taxa_conv_otb) >= 5 
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>{percentages.taxa_conv_otb}%</div>
            </div>

            {/* TOTAL Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center border-t border-slate-700 pt-2">
              <div className="flex items-center gap-1">
                <span className="text-green-400 font-semibold text-sm">TOTAL</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.prospec_otb.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_total.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_leads_qualif_total}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_total.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_qualif_agend_total}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_total}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_agend_calls_total}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.noshow_total}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_noshow_total}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_total}</div>
              <div className="text-center text-gray-300 text-sm">{percentages.pct_calls_venda_total}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_total}</div>
              <div className="text-center text-gray-300 text-sm">—</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.perdido_total.toLocaleString('pt-BR')}</div>
              <div className={`rounded px-2 py-1 text-center font-bold text-sm ${
                parseFloat(percentages.taxa_conv_total) >= 5 
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>{percentages.taxa_conv_total}%</div>
            </div>
          </div>

          {/* TABELA MENSAL COM SCROLL HORIZONTAL */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            <h3 className="text-gray-300 text-sm font-semibold mb-4">Dados por Mês</h3>
            <div className="overflow-x-auto">
              <table className="text-sm whitespace-nowrap w-full">
                <thead>
                  <tr className="text-gray-400 border-b border-slate-700">
                    <th className="text-left py-2 px-3 sticky left-0 bg-slate-900 z-10">Mês</th>
                    <th className="text-right py-2 px-3">Leads TRAF</th>
                    <th className="text-right py-2 px-3">Leads BPO</th>
                    <th className="text-right py-2 px-3">Total</th>
                    <th className="text-right py-2 px-3">Qualif TRAF</th>
                    <th className="text-right py-2 px-3">Qualif BPO</th>
                    <th className="text-right py-2 px-3">Agend TRAF</th>
                    <th className="text-right py-2 px-3">Agend BPO</th>
                    <th className="text-right py-2 px-3">Calls TRAF</th>
                    <th className="text-right py-2 px-3">Calls BPO</th>
                    <th className="text-right py-2 px-3">Ganhos TRAF</th>
                    <th className="text-right py-2 px-3">Ganhos BPO</th>
                  </tr>
                </thead>
                <tbody>
                  {monthlyData.map((row, index) => (
                    <tr key={index} className="text-white border-b border-slate-800 hover:bg-slate-800/30">
                      <td className="py-2 px-3 text-cyan-400 sticky left-0 bg-slate-900">{row.mes}</td>
                      <td className="py-2 px-3 text-right text-green-400">{row.leads_traf}</td>
                      <td className="py-2 px-3 text-right text-orange-400">{row.leads_bpo}</td>
                      <td className="py-2 px-3 text-right font-bold">{row.leads_total}</td>
                      <td className="py-2 px-3 text-right text-green-400">{row.qualif_traf}</td>
                      <td className="py-2 px-3 text-right text-orange-400">{row.qualif_bpo}</td>
                      <td className="py-2 px-3 text-right text-green-400">{row.agend_traf}</td>
                      <td className="py-2 px-3 text-right text-orange-400">{row.agend_bpo}</td>
                      <td className="py-2 px-3 text-right text-green-400">{row.calls_traf}</td>
                      <td className="py-2 px-3 text-right text-orange-400">{row.calls_bpo}</td>
                      <td className="py-2 px-3 text-right text-green-400">{row.ganhos_traf}</td>
                      <td className="py-2 px-3 text-right text-orange-400">{row.ganhos_bpo}</td>
                    </tr>
                  ))}
                  {monthlyData.length === 0 && (
                    <tr>
                      <td colSpan={12} className="py-8 text-center text-gray-500">
                        Nenhum dado mensal disponível
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
