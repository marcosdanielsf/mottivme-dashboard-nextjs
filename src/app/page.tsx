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

        // Investimentos (mock por enquanto - depois vir do Supabase)
        const inv_trafego = 0;
        const inv_bpo = 0;

        // SAL = total de leads
        const sal = monthMetrics.leads_total;

        // Total agendados
        const leads_agd = monthMetrics.leads_agend_total;

        // Percentuais
        const pct_agd = sal > 0 ? Math.round((leads_agd / sal) * 100) : 0;
        const tt_calls = monthMetrics.calls_total;
        const pct_calls = leads_agd > 0 ? Math.round((tt_calls / leads_agd) * 100) : 0;
        const tt_ganhos = monthMetrics.leads_venda_total;
        const pct_ganhos = tt_calls > 0 ? Math.round((tt_ganhos / tt_calls) * 100) : 0;

        // CPL (Custo Por Lead)
        const cpl_traf = monthMetrics.leads_traf > 0 && inv_trafego > 0
          ? inv_trafego / monthMetrics.leads_traf
          : 0;
        const cpl_bpo = monthMetrics.leads_otb > 0 && inv_bpo > 0
          ? inv_bpo / monthMetrics.leads_otb
          : 0;

        // CPRA (Custo Por Reunião Agendada)
        const cpra_traf = monthMetrics.leads_agend_traf > 0 && inv_trafego > 0
          ? inv_trafego / monthMetrics.leads_agend_traf
          : 0;
        const cpra_bpo = monthMetrics.leads_agend_otb > 0 && inv_bpo > 0
          ? inv_bpo / monthMetrics.leads_agend_otb
          : 0;

        // CPA (Custo Por Aquisição)
        const cpa_traf = monthMetrics.leads_venda_traf > 0 && inv_trafego > 0
          ? inv_trafego / monthMetrics.leads_venda_traf
          : 0;
        const cpa_bpo = monthMetrics.leads_venda_otb > 0 && inv_bpo > 0
          ? inv_bpo / monthMetrics.leads_venda_otb
          : 0;

        monthRows.push({
          mes: mesCapitalized,
          inv_trafego,
          inv_bpo,
          sal,
          pct_agd,
          leads_agd,
          pct_calls,
          tt_calls,
          pct_ganhos,
          tt_ganhos,
          tl_agd_traf: monthMetrics.leads_agend_traf,
          tl_agd_bpo: monthMetrics.leads_agend_otb,
          calls_traf: monthMetrics.calls_traf,
          calls_bpo: monthMetrics.calls_otb,
          ganhos_traf: monthMetrics.leads_venda_traf,
          ganhos_bpo: monthMetrics.leads_venda_otb,
          cpl_traf,
          cpl_bpo,
          cpra_traf,
          cpra_bpo,
          cpa_traf,
          cpa_bpo,
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
            <div className="overflow-x-auto">
              <table className="text-sm whitespace-nowrap w-full">
                <thead>
                  <tr className="text-gray-400 border-b border-slate-700">
                    <th className="text-left py-2 px-3 sticky left-0 bg-slate-900 z-10">Mês</th>
                    <th className="text-right py-2 px-3">Inv Tráfego</th>
                    <th className="text-right py-2 px-3">Inv BPO</th>
                    <th className="text-right py-2 px-3">SAL</th>
                    <th className="text-right py-2 px-3">% Agd</th>
                    <th className="text-right py-2 px-3">Leads Agd</th>
                    <th className="text-right py-2 px-3">% Calls</th>
                    <th className="text-right py-2 px-3">TT Calls</th>
                    <th className="text-right py-2 px-3">% Ganhos</th>
                    <th className="text-right py-2 px-3">TT Ganhos</th>
                    <th className="text-right py-2 px-3">Tl agd TRAF</th>
                    <th className="text-right py-2 px-3">Tl agd BPO</th>
                    <th className="text-right py-2 px-3">Calls TRAF</th>
                    <th className="text-right py-2 px-3">Calls BPO</th>
                    <th className="text-right py-2 px-3">Ganhos TRAF</th>
                    <th className="text-right py-2 px-3">Ganhos BPO</th>
                    <th className="text-right py-2 px-3">CPL TRAF</th>
                    <th className="text-right py-2 px-3">CPL BPO</th>
                    <th className="text-right py-2 px-3">CPRA TRAF</th>
                    <th className="text-right py-2 px-3">CPRA BPO</th>
                    <th className="text-right py-2 px-3">CPA TRAF</th>
                    <th className="text-right py-2 px-3">CPA BPO</th>
                  </tr>
                </thead>
                <tbody>
                  {monthlyData.map((row, index) => (
                    <tr key={index} className="text-white border-b border-slate-800 hover:bg-slate-800/30">
                      <td className="py-2 px-3 text-cyan-400 sticky left-0 bg-slate-900">{row.mes}</td>
                      <td className="py-2 px-3 text-right text-green-400">R$ {row.inv_trafego.toLocaleString('pt-BR')}</td>
                      <td className="py-2 px-3 text-right text-orange-400">R$ {row.inv_bpo.toLocaleString('pt-BR')}</td>
                      <td className="py-2 px-3 text-right">{row.sal}</td>
                      <td className="py-2 px-3 text-right">{row.pct_agd}%</td>
                      <td className="py-2 px-3 text-right">{row.leads_agd}</td>
                      <td className="py-2 px-3 text-right">{row.pct_calls}%</td>
                      <td className="py-2 px-3 text-right">{row.tt_calls}</td>
                      <td className="py-2 px-3 text-right">{row.pct_ganhos}%</td>
                      <td className="py-2 px-3 text-right">{row.tt_ganhos}</td>
                      <td className="py-2 px-3 text-right">{row.tl_agd_traf}</td>
                      <td className="py-2 px-3 text-right">{row.tl_agd_bpo}</td>
                      <td className="py-2 px-3 text-right">{row.calls_traf}</td>
                      <td className="py-2 px-3 text-right">{row.calls_bpo}</td>
                      <td className="py-2 px-3 text-right">{row.ganhos_traf}</td>
                      <td className="py-2 px-3 text-right">{row.ganhos_bpo}</td>
                      <td className="py-2 px-3 text-right text-green-400">${row.cpl_traf.toFixed(2)}</td>
                      <td className="py-2 px-3 text-right text-orange-400">${row.cpl_bpo.toFixed(2)}</td>
                      <td className="py-2 px-3 text-right text-green-400">${row.cpra_traf.toFixed(2)}</td>
                      <td className="py-2 px-3 text-right text-orange-400">${row.cpra_bpo.toFixed(2)}</td>
                      <td className="py-2 px-3 text-right text-green-400">${row.cpa_traf.toLocaleString('pt-BR')}</td>
                      <td className="py-2 px-3 text-right text-orange-400">${row.cpa_bpo.toLocaleString('pt-BR')}</td>
                    </tr>
                  ))}
                  {monthlyData.length === 0 && (
                    <tr>
                      <td colSpan={22} className="py-8 text-center text-gray-500">
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
