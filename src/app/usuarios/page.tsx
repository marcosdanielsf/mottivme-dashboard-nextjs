'use client';

import { useState } from 'react';
import Sidebar from '@/components/Sidebar';
import type { UserData, DashboardMetrics } from '@/types';

const mockMetrics: DashboardMetrics = {
  leads_traf: 1993, leads_qualif_traf: 1832, leads_agend_traf: 582, leads_noshow_traf: 110, calls_traf: 136, leads_venda_traf: 1, leads_desqualif_traf: 161, pct_leads_qualif_traf: 92, pct_qualif_agend_traf: 32, pct_agend_calls_traf: 19, pct_calls_venda_traf: 1, prospec_otb: 34709, leads_otb: 3667, leads_qualif_otb: 2668, leads_agend_otb: 366, leads_noshow_otb: 64, calls_otb: 104, leads_venda_otb: 29, leads_desqualif_otb: 999, pct_leads_qualif_otb: 73, pct_qualif_agend_otb: 14, pct_agend_calls_otb: 17, pct_calls_venda_otb: 28, leads_total: 5660, leads_qualif_total: 4500, leads_agend_total: 948, calls_total: 240, leads_venda_total: 30, noshow_total: 174, perdido_total: 1160, taxa_conv_total: 5.68, pct_leads_qualif_total: 80,
};

const mockUserData: UserData[] = [
  { user: 'Andre Rosa', inv_trafego: 3600, inv_bpo: 1800, sal: 966, pct_agd: 33, leads_agd: 314, pct_calls: 23, tt_calls: 73, pct_ganhos: 18, tt_ganhos: 13, tl_agd_traf: 188, tl_agd_bpo: 126, calls_traf: 42, calls_bpo: 31, ganhos_traf: 5, ganhos_bpo: 8, cpl_traf: 5.63, cpl_bpo: 4.29, cpra_traf: 19.15, cpra_bpo: 14.29, cpa_traf: 720, cpa_bpo: 225 },
  { user: 'Taci e Marcos', inv_trafego: 3950, inv_bpo: 3000, sal: 549, pct_agd: 27, leads_agd: 147, pct_calls: 51, tt_calls: 75, pct_ganhos: 5, tt_ganhos: 4, tl_agd_traf: 98, tl_agd_bpo: 49, calls_traf: 51, calls_bpo: 24, ganhos_traf: 2, ganhos_bpo: 2, cpl_traf: 12.35, cpl_bpo: 9.18, cpra_traf: 40.31, cpra_bpo: 61.22, cpa_traf: 1975, cpa_bpo: 1500 },
  { user: 'Aline Morais', inv_trafego: 3600, inv_bpo: 1800, sal: 887, pct_agd: 15, leads_agd: 130, pct_calls: 3, tt_calls: 4, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 85, tl_agd_bpo: 45, calls_traf: 2, calls_bpo: 2, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 12.00, cpl_bpo: 5.71, cpra_traf: 42.35, cpra_bpo: 40.00, cpa_traf: 0, cpa_bpo: 0 },
  { user: 'Fernanda Lappe', inv_trafego: 1600, inv_bpo: 2400, sal: 679, pct_agd: 12, leads_agd: 82, pct_calls: 9, tt_calls: 7, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 45, tl_agd_bpo: 37, calls_traf: 4, calls_bpo: 3, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 8.89, cpl_bpo: 8.11, cpra_traf: 35.56, cpra_bpo: 64.86, cpa_traf: 0, cpa_bpo: 0 },
  { user: 'Gladson Almeida', inv_trafego: 3000, inv_bpo: 1695, sal: 365, pct_agd: 12, leads_agd: 44, pct_calls: 27, tt_calls: 12, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 28, tl_agd_bpo: 16, calls_traf: 8, calls_bpo: 4, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 26.79, cpl_bpo: 15.86, cpra_traf: 107.14, cpra_bpo: 105.94, cpa_traf: 0, cpa_bpo: 0 },
  { user: 'Matheus Dias', inv_trafego: 1800, inv_bpo: 1800, sal: 298, pct_agd: 13, leads_agd: 40, pct_calls: 8, tt_calls: 3, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 25, tl_agd_bpo: 15, calls_traf: 2, calls_bpo: 1, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 22.50, cpl_bpo: 17.14, cpra_traf: 72.00, cpra_bpo: 120.00, cpa_traf: 0, cpa_bpo: 0 },
  { user: 'Milton', inv_trafego: 600, inv_bpo: 1000, sal: 147, pct_agd: 25, leads_agd: 37, pct_calls: 32, tt_calls: 12, pct_ganhos: 8, tt_ganhos: 1, tl_agd_traf: 22, tl_agd_bpo: 15, calls_traf: 7, calls_bpo: 5, ganhos_traf: 0, ganhos_bpo: 1, cpl_traf: 12.00, cpl_bpo: 9.52, cpra_traf: 27.27, cpra_bpo: 66.67, cpa_traf: 0, cpa_bpo: 1000 },
  { user: 'Juliana Costa', inv_trafego: 1800, inv_bpo: 2200, sal: 250, pct_agd: 9, leads_agd: 22, pct_calls: 14, tt_calls: 3, pct_ganhos: 0, tt_ganhos: 0, tl_agd_traf: 14, tl_agd_bpo: 8, calls_traf: 2, calls_bpo: 1, ganhos_traf: 0, ganhos_bpo: 0, cpl_traf: 32.14, cpl_bpo: 31.43, cpra_traf: 128.57, cpra_bpo: 275.00, cpa_traf: 0, cpa_bpo: 0 },
];

export default function UsuariosPage() {
  const [metrics] = useState<DashboardMetrics>(mockMetrics);
  const [userData] = useState<UserData[]>(mockUserData);

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />
      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          <h1 className="text-2xl font-light"><span className="text-white">Overview</span> <span className="text-cyan-400">Usuários</span></h1>

          {/* FUNIL */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 text-center text-xs text-gray-400 mb-3">
              <div></div><div>Prospec</div><div>Lead</div><div>%</div><div>Qualif</div><div>%</div><div>Agend</div><div>%</div><div>NoShow</div><div>%</div><div>Calls</div><div>%</div><div>Ganho</div><div>%</div><div>Perdido</div><div>Tx Conv</div>
            </div>
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1"><span className="text-cyan-400 font-semibold text-sm">TRÁFEGO</span><span className="text-gray-500">▶</span></div>
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
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center mb-2">
              <div className="flex items-center gap-1"><span className="text-cyan-400 font-semibold text-sm">BPO</span><span className="text-gray-500">▶</span></div>
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
            <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center border-t border-slate-700 pt-2">
              <div className="flex items-center gap-1"><span className="text-green-400 font-semibold text-sm">TOTAL</span><span className="text-gray-500">▶</span></div>
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

          {/* TABELA */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            <div className="overflow-x-auto">
              <table className="text-sm whitespace-nowrap w-full">
                <thead>
                  <tr className="text-gray-400 border-b border-slate-700">
                    <th className="text-left py-2 px-3 sticky left-0 bg-slate-900 z-10">User</th>
                    <th className="text-right py-2 px-3">Inv Tráfego</th><th className="text-right py-2 px-3">Inv BPO</th><th className="text-right py-2 px-3">SAL</th><th className="text-right py-2 px-3">% Agd</th><th className="text-right py-2 px-3">Leads Agd</th><th className="text-right py-2 px-3">% Calls</th><th className="text-right py-2 px-3">TT Calls</th><th className="text-right py-2 px-3">% Ganhos</th><th className="text-right py-2 px-3">TT Ganhos</th><th className="text-right py-2 px-3">Tl agd TRAF</th><th className="text-right py-2 px-3">Tl agd BPO</th><th className="text-right py-2 px-3">Calls TRAF</th><th className="text-right py-2 px-3">Calls BPO</th><th className="text-right py-2 px-3">Ganhos TRAF</th><th className="text-right py-2 px-3">Ganhos BPO</th><th className="text-right py-2 px-3">CPL TRAF</th><th className="text-right py-2 px-3">CPL BPO</th><th className="text-right py-2 px-3">CPRA TRAF</th><th className="text-right py-2 px-3">CPRA BPO</th><th className="text-right py-2 px-3">CPA TRAF</th><th className="text-right py-2 px-3">CPA BPO</th>
                  </tr>
                </thead>
                <tbody>
                  {userData.map((row, i) => (
                    <tr key={i} className="text-white border-b border-slate-800 hover:bg-slate-800/30">
                      <td className="py-2 px-3 text-cyan-400 sticky left-0 bg-slate-900">{row.user}</td>
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
                  <tr className="text-white bg-slate-800/50 font-semibold">
                    <td className="py-2 px-3 text-green-400 sticky left-0 bg-slate-800">Total</td>
                    <td className="py-2 px-3 text-right text-green-400">R$ 25.350</td><td className="py-2 px-3 text-right text-orange-400">R$ 31.695</td><td className="py-2 px-3 text-right">5.416</td><td className="py-2 px-3 text-right">17%</td><td className="py-2 px-3 text-right">898</td><td className="py-2 px-3 text-right">25%</td><td className="py-2 px-3 text-right">226</td><td className="py-2 px-3 text-right">11%</td><td className="py-2 px-3 text-right">25</td><td className="py-2 px-3 text-right">549</td><td className="py-2 px-3 text-right">349</td><td className="py-2 px-3 text-right">131</td><td className="py-2 px-3 text-right">95</td><td className="py-2 px-3 text-right">7</td><td className="py-2 px-3 text-right">18</td><td className="py-2 px-3 text-right text-green-400">$13,34</td><td className="py-2 px-3 text-right text-orange-400">$9,02</td><td className="py-2 px-3 text-right text-green-400">$46,17</td><td className="py-2 px-3 text-right text-orange-400">$90,82</td><td className="py-2 px-3 text-right text-green-400">$25.350</td><td className="py-2 px-3 text-right text-orange-400">$1.320,63</td>
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
