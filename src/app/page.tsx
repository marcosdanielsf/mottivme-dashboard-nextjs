'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { getTotaisFunil } from '@/lib/queries';

interface TotaisCanal {
  total_leads: number
  leads_qualificados: number
  leads_agendados: number
  leads_noshow: number
  leads_calls: number
  leads_ganhos: number
  leads_perdidos: number
}

// Dados mockados da tabela mensal (manter até criar view específica)
const mockMonthlyData = [
  { mes: 'Janeiro', inv_trafego: 6500, inv_bpo: 9765, sal: 2277, pct_agd: 13, leads_agd: 285, pct_calls: 32, tt_calls: 91, pct_ganhos: 9, tt_ganhos: 8, tl_agd_traf: 153, tl_agd_bpo: 132, calls_traf: 42, calls_bpo: 49, ganhos_traf: 1, ganhos_bpo: 7, cpl_traf: 10.87, cpl_bpo: 5.82, cpra_traf: 42.48, cpra_bpo: 73.98, cpa_traf: 6500, cpa_bpo: 1395 },
  { mes: 'Fevereiro', inv_trafego: 8300, inv_bpo: 10715, sal: 1765, pct_agd: 19, leads_agd: 341, pct_calls: 29, tt_calls: 100, pct_ganhos: 17, tt_ganhos: 17, tl_agd_traf: 203, tl_agd_bpo: 138, calls_traf: 63, calls_bpo: 37, ganhos_traf: 0, ganhos_bpo: 17, cpl_traf: 12.41, cpl_bpo: 9.78, cpra_traf: 40.89, cpra_bpo: 77.64, cpa_traf: 0, cpa_bpo: 630.29 },
  { mes: 'Março', inv_trafego: 10550, inv_bpo: 11215, sal: 1534, pct_agd: 19, leads_agd: 294, pct_calls: 17, tt_calls: 49, pct_ganhos: 10, tt_ganhos: 5, tl_agd_traf: 201, tl_agd_bpo: 93, calls_traf: 31, calls_bpo: 18, ganhos_traf: 0, ganhos_bpo: 5, cpl_traf: 16.06, cpl_bpo: 12.79, cpra_traf: 52.49, cpra_bpo: 120.59, cpa_traf: 0, cpa_bpo: 2243 },
  { mes: 'Abril', inv_trafego: 0, inv_bpo: 0, sal: 84, pct_agd: 33, leads_agd: 28, pct_calls: 0, tt_calls: 0, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 25, tl_agd_bpo: 3, calls_traf: 0, calls_bpo: 0, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 0, cpl_bpo: 0, cpra_traf: 0, cpra_bpo: 0, cpa_traf: 0, cpa_bpo: 0 },
];

export default function HomePage() {
  const [totais, setTotais] = useState<{ trafego: TotaisCanal, bpo: TotaisCanal } | null>(null);
  const [loading, setLoading] = useState(true);
  const [monthlyData] = useState(mockMonthlyData);

  useEffect(() => {
    async function fetchData() {
      setLoading(true);
      try {
        const totaisData = await getTotaisFunil();
        setTotais(totaisData);
      } catch (error) {
        console.error('Erro ao carregar dados:', error);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <div className="text-cyan-400 text-xl">Carregando...</div>
      </div>
    );
  }

  // Calcular valores
  const trafego = totais?.trafego || { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 };
  const bpo = totais?.bpo || { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 };

  const trafegoTotal = trafego.total_leads || 0;
  const bpoTotal = bpo.total_leads || 0;
  const totalGeral = trafegoTotal + bpoTotal;

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
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafegoTotal.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{trafegoTotal > 0 ? ((trafego.leads_qualificados / trafegoTotal) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_qualificados.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{trafego.leads_qualificados > 0 ? ((trafego.leads_agendados / trafego.leads_qualificados) * 100).toFixed(0) : 0}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_agendados}</div>
              <div className="text-center text-gray-300 text-sm">{trafego.leads_agendados > 0 ? ((trafego.leads_calls / trafego.leads_agendados) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_noshow}</div>
              <div className="text-center text-gray-300 text-sm">{trafego.leads_agendados > 0 ? ((trafego.leads_noshow / trafego.leads_agendados) * 100).toFixed(0) : 0}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_calls}</div>
              <div className="text-center text-gray-300 text-sm">{trafego.leads_calls > 0 ? ((trafego.leads_ganhos / trafego.leads_calls) * 100).toFixed(0) : 0}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_ganhos}</div>
              <div className="text-center text-gray-300 text-sm">{trafego.leads_calls > 0 ? ((trafego.leads_ganhos / trafego.leads_calls) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_perdidos}</div>
              <div className={`text-center rounded px-1 font-bold text-sm ${
                trafegoTotal > 0 && (trafego.leads_ganhos / trafegoTotal) * 100 >= 5
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>
                {trafegoTotal > 0 ? ((trafego.leads_ganhos / trafegoTotal) * 100).toFixed(2) : '0.00'}%
              </div>
            </div>

            {/* BPO Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1">
                <span className="text-cyan-400 font-semibold text-sm">BPO</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpoTotal.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_qualificados.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{bpoTotal > 0 ? ((bpo.leads_qualificados / bpoTotal) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_qualificados.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">100%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_agendados}</div>
              <div className="text-center text-gray-300 text-sm">{bpo.leads_agendados > 0 ? ((bpo.leads_calls / bpo.leads_agendados) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_noshow}</div>
              <div className="text-center text-gray-300 text-sm">{bpo.leads_agendados > 0 ? ((bpo.leads_noshow / bpo.leads_agendados) * 100).toFixed(0) : 0}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_calls}</div>
              <div className="text-center text-gray-300 text-sm">{bpo.leads_calls > 0 ? ((bpo.leads_ganhos / bpo.leads_calls) * 100).toFixed(0) : 0}%</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_ganhos}</div>
              <div className="text-center text-gray-300 text-sm">{bpo.leads_calls > 0 ? ((bpo.leads_ganhos / bpo.leads_calls) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpo.leads_perdidos}</div>
              <div className={`text-center rounded px-1 font-bold text-sm ${
                bpoTotal > 0 && (bpo.leads_ganhos / bpoTotal) * 100 >= 5
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>
                {bpoTotal > 0 ? ((bpo.leads_ganhos / bpoTotal) * 100).toFixed(2) : '0.00'}%
              </div>
            </div>

            {/* TOTAL Row */}
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center border-t border-slate-700 pt-2">
              <div className="flex items-center gap-1">
                <span className="text-green-400 font-semibold text-sm">TOTAL</span>
                <span className="text-gray-500">▶</span>
              </div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{bpoTotal.toLocaleString('pt-BR')}</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{totalGeral.toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">{totalGeral > 0 ? (((trafego.leads_qualificados + bpo.leads_qualificados) / totalGeral) * 100).toFixed(0) : 0}%</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{(trafego.leads_qualificados + bpo.leads_qualificados).toLocaleString('pt-BR')}</div>
              <div className="text-center text-gray-300 text-sm">-</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_agendados + bpo.leads_agendados}</div>
              <div className="text-center text-gray-300 text-sm">-</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_noshow + bpo.leads_noshow}</div>
              <div className="text-center text-gray-300 text-sm">-</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_calls + bpo.leads_calls}</div>
              <div className="text-center text-gray-300 text-sm">-</div>
              <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">{trafego.leads_ganhos + bpo.leads_ganhos}</div>
              <div className="text-center text-gray-300 text-sm">—</div>
              <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">{(trafego.leads_perdidos + bpo.leads_perdidos).toLocaleString('pt-BR')}</div>
              <div className={`text-center rounded px-1 font-bold text-sm ${
                totalGeral > 0 && ((trafego.leads_ganhos + bpo.leads_ganhos) / totalGeral) * 100 >= 5
                  ? 'bg-green-500/20 border border-green-500 text-green-400'
                  : 'bg-red-500/20 border border-red-500 text-red-400'
              }`}>
                {totalGeral > 0 ? (((trafego.leads_ganhos + bpo.leads_ganhos) / totalGeral) * 100).toFixed(2) : '0.00'}%
              </div>
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
