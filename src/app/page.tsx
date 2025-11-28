'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { supabase } from '@/lib/supabase';
import type { DashboardMetrics, MonthlyData } from '@/types';

// Dados mockados para demonstração (substituir por Supabase depois)
const mockMetrics: DashboardMetrics = {
  leads_traf: 1993,
  leads_qualif_traf: 1832,
  leads_agend_traf: 582,
  leads_noshow_traf: 110,
  calls_traf: 136,
  leads_venda_traf: 1,
  leads_desqualif_traf: 161,
  pct_leads_qualif_traf: 92,
  pct_qualif_agend_traf: 32,
  pct_agend_calls_traf: 19,
  pct_calls_venda_traf: 1,
  prospec_otb: 34709,
  leads_otb: 3667,
  leads_qualif_otb: 2668,
  leads_agend_otb: 366,
  leads_noshow_otb: 64,
  calls_otb: 104,
  leads_venda_otb: 29,
  leads_desqualif_otb: 999,
  pct_leads_qualif_otb: 73,
  pct_qualif_agend_otb: 14,
  pct_agend_calls_otb: 17,
  pct_calls_venda_otb: 28,
  leads_total: 5660,
  leads_qualif_total: 4500,
  leads_agend_total: 948,
  calls_total: 240,
  leads_venda_total: 30,
  noshow_total: 174,
  perdido_total: 1160,
  taxa_conv_total: 5.68,
  pct_leads_qualif_total: 80,
};

const mockMonthlyData: MonthlyData[] = [
  { mes: 'Janeiro', inv_trafego: 6500, inv_bpo: 9765, sal: 2277, pct_agd: 13, leads_agd: 285, pct_calls: 32, tt_calls: 91, pct_ganhos: 9, tt_ganhos: 8, tl_agd_traf: 153, tl_agd_bpo: 132, calls_traf: 42, calls_bpo: 49, ganhos_traf: 1, ganhos_bpo: 7, cpl_traf: 10.87, cpl_bpo: 5.82, cpra_traf: 42.48, cpra_bpo: 73.98, cpa_traf: 6500, cpa_bpo: 1395 },
  { mes: 'Fevereiro', inv_trafego: 8300, inv_bpo: 10715, sal: 1765, pct_agd: 19, leads_agd: 341, pct_calls: 29, tt_calls: 100, pct_ganhos: 17, tt_ganhos: 17, tl_agd_traf: 203, tl_agd_bpo: 138, calls_traf: 63, calls_bpo: 37, ganhos_traf: 0, ganhos_bpo: 17, cpl_traf: 12.41, cpl_bpo: 9.78, cpra_traf: 40.89, cpra_bpo: 77.64, cpa_traf: 0, cpa_bpo: 630.29 },
  { mes: 'Março', inv_trafego: 10550, inv_bpo: 11215, sal: 1534, pct_agd: 19, leads_agd: 294, pct_calls: 17, tt_calls: 49, pct_ganhos: 10, tt_ganhos: 5, tl_agd_traf: 201, tl_agd_bpo: 93, calls_traf: 31, calls_bpo: 18, ganhos_traf: 0, ganhos_bpo: 5, cpl_traf: 16.06, cpl_bpo: 12.79, cpra_traf: 52.49, cpra_bpo: 120.59, cpa_traf: 0, cpa_bpo: 2243 },
  { mes: 'Abril', inv_trafego: 0, inv_bpo: 0, sal: 84, pct_agd: 33, leads_agd: 28, pct_calls: 0, tt_calls: 0, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 25, tl_agd_bpo: 3, calls_traf: 0, calls_bpo: 0, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 0, cpl_bpo: 0, cpra_traf: 0, cpra_bpo: 0, cpa_traf: 0, cpa_bpo: 0 },
];

export default function HomePage() {
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [monthlyData, setMonthlyData] = useState<MonthlyData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      // Buscar métricas do funil
      const { data: metricsData, error: metricsError } = await supabase
        .from('powerbi_dashboard_metrics')
        .select('*')
        .single();

      if (metricsError) {
        console.error('Erro ao buscar métricas:', metricsError);
        // Usar dados mockados como fallback
        setMetrics(mockMetrics);
      } else if (metricsData) {
        setMetrics(metricsData);
      }

      // Buscar dados mensais
      const { data: monthlyDataResult, error: monthlyError } = await supabase
        .from('monthly_data')
        .select('*')
        .order('month_num', { ascending: true });

      if (monthlyError) {
        console.error('Erro ao buscar dados mensais:', monthlyError);
        // Usar dados mockados como fallback
        setMonthlyData(mockMonthlyData);
      } else if (monthlyDataResult) {
        setMonthlyData(monthlyDataResult);
      }
    } catch (error) {
      console.error('Erro:', error);
      // Usar dados mockados como fallback em caso de erro
      setMetrics(mockMetrics);
      setMonthlyData(mockMonthlyData);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <div className="text-cyan-400 text-xl">Carregando...</div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />

      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          {/* Title */}
          <h1 className="text-2xl font-light">
            <span className="text-white">Overview</span>{' '}
            <span className="text-cyan-400">Comercial</span>
          </h1>

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
              <div className="text-center text-gray-300 text-sm">{metrics.pct_leads_qualif_traf}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_traf.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_qualif_agend_traf}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_traf}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_agend_calls_traf}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_noshow_traf}</div>
              <div className="text-center text-gray-300 text-sm">23%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_traf}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_calls_venda_traf}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_traf}</div>
              <div className="text-center text-gray-300 text-sm">8%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_desqualif_traf}</div>
              <div className="bg-red-500/20 border border-red-500 rounded px-2 py-1 text-center text-red-400 font-bold text-sm">0,30%</div>
            </div>

            {/* BPO Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1">
                <span className="text-cyan-400 font-semibold text-sm">BPO</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.prospec_otb.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_otb.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_leads_qualif_otb}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_otb.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_qualif_agend_otb}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_otb}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_agend_calls_otb}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_noshow_otb}</div>
              <div className="text-center text-gray-300 text-sm">28%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_otb}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_calls_venda_otb}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_otb}</div>
              <div className="text-center text-gray-300 text-sm">27%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_desqualif_otb}</div>
              <div className="bg-green-500/20 border border-green-500 rounded px-2 py-1 text-center text-green-400 font-bold text-sm">14,80%</div>
            </div>

            {/* TOTAL Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center border-t border-slate-700 pt-2">
              <div className="flex items-center gap-1">
                <span className="text-green-400 font-semibold text-sm">TOTAL</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.prospec_otb.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_total.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{metrics.pct_leads_qualif_total}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_qualif_total.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">21%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_agend_total}</div>
              <div className="text-center text-gray-300 text-sm">18%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.noshow_total}</div>
              <div className="text-center text-gray-300 text-sm">25%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.calls_total}</div>
              <div className="text-center text-gray-300 text-sm">13%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.leads_venda_total}</div>
              <div className="text-center text-gray-300 text-sm">—</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{metrics.perdido_total.toLocaleString('pt-BR')}</div>
              <div className="bg-green-500/20 border border-green-500 rounded px-2 py-1 text-center text-green-400 font-bold text-sm">{metrics.taxa_conv_total}%</div>
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
                      <td className="py-2 px-3 text-right">{row.sal.toLocaleString('pt-BR')}</td>
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
                  {/* Total Row */}
                  <tr className="text-white bg-slate-800/50 font-semibold">
                    <td className="py-2 px-3 text-green-400 sticky left-0 bg-slate-800">Total</td>
                    <td className="py-2 px-3 text-right text-green-400">R$ 25.350</td>
                    <td className="py-2 px-3 text-right text-orange-400">R$ 31.695</td>
                    <td className="py-2 px-3 text-right">5.660</td>
                    <td className="py-2 px-3 text-right">17%</td>
                    <td className="py-2 px-3 text-right">948</td>
                    <td className="py-2 px-3 text-right">25%</td>
                    <td className="py-2 px-3 text-right">240</td>
                    <td className="py-2 px-3 text-right">13%</td>
                    <td className="py-2 px-3 text-right">30</td>
                    <td className="py-2 px-3 text-right">582</td>
                    <td className="py-2 px-3 text-right">366</td>
                    <td className="py-2 px-3 text-right">136</td>
                    <td className="py-2 px-3 text-right">104</td>
                    <td className="py-2 px-3 text-right">1</td>
                    <td className="py-2 px-3 text-right">29</td>
                    <td className="py-2 px-3 text-right text-green-400">$13,34</td>
                    <td className="py-2 px-3 text-right text-orange-400">$9,02</td>
                    <td className="py-2 px-3 text-right text-green-400">$43,55</td>
                    <td className="py-2 px-3 text-right text-orange-400">$86,60</td>
                    <td className="py-2 px-3 text-right text-green-400">$25.350</td>
                    <td className="py-2 px-3 text-right text-orange-400">$1.093</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
