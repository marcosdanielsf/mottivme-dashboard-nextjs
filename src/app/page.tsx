'use client'

import { useEffect, useState } from 'react'
import Sidebar from '@/components/Sidebar'
import { getTotaisFunil, getMetricasFunil, getInvestimentos } from '@/lib/queries'
import type { MetricasFunil, Investimento } from '@/types'

interface TotaisCanal {
  total_leads: number
  leads_qualificados: number
  leads_agendados: number
  leads_noshow: number
  leads_calls: number
  leads_ganhos: number
  leads_perdidos: number
}

export default function Home() {
  const [loading, setLoading] = useState(true)
  const [totais, setTotais] = useState<{ trafego: TotaisCanal, bpo: TotaisCanal } | null>(null)
  const [metricas, setMetricas] = useState<MetricasFunil[]>([])
  const [investimentos, setInvestimentos] = useState<Investimento[]>([])

  useEffect(() => {
    async function fetchData() {
      setLoading(true)
      try {
        const [totaisData, metricasData, investData] = await Promise.all([
          getTotaisFunil(),
          getMetricasFunil(2025), // Ano atual
          getInvestimentos(2025)
        ])

        setTotais(totaisData)
        setMetricas(metricasData)
        setInvestimentos(investData)
      } catch (error) {
        console.error('Erro ao carregar dados:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
        <Sidebar />
        <main className="flex-1 ml-[230px] p-6">
          <div className="flex items-center justify-center h-full">
            <div className="text-white text-xl">Carregando dados...</div>
          </div>
        </main>
      </div>
    )
  }

  // Calcular percentuais
  const trafego = totais?.trafego || { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 }
  const bpo = totais?.bpo || { total_leads: 0, leads_qualificados: 0, leads_agendados: 0, leads_noshow: 0, leads_calls: 0, leads_ganhos: 0, leads_perdidos: 0 }

  const trafegoTotal = trafego.total_leads || 0
  const bpoTotal = bpo.total_leads || 0
  const totalGeral = trafegoTotal + bpoTotal

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />
      <main className="flex-1 ml-[230px] p-6">
        <h1 className="text-2xl font-bold text-white mb-6">Overview Comercial</h1>

        {/* Funil de métricas */}
        <div className="bg-slate-900/50 rounded-lg border border-slate-800 p-4 mb-6">
          <div className="grid grid-cols-[100px_repeat(16,1fr)] gap-1 text-xs">
            {/* Header */}
            <div className="text-gray-400"></div>
            <div className="text-gray-400 text-center">Prospec</div>
            <div className="text-gray-400 text-center">Lead</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">Qualif</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">Agend</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">NoShow</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">Calls</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">Ganho</div>
            <div className="text-gray-400 text-center">%</div>
            <div className="text-gray-400 text-center">Perdido</div>
            <div className="text-gray-400 text-center">Tx Conv</div>

            {/* TRÁFEGO */}
            <div className="text-cyan-400 font-semibold">TRÁFEGO</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">-</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{trafegoTotal}</div>
            <div className="text-gray-300 text-center">100%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{trafego.leads_qualificados || 0}</div>
            <div className="text-gray-300 text-center">{trafegoTotal > 0 ? ((trafego.leads_qualificados / trafegoTotal) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{trafego.leads_agendados || 0}</div>
            <div className="text-gray-300 text-center">{trafego.leads_qualificados > 0 ? ((trafego.leads_agendados / trafego.leads_qualificados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{trafego.leads_noshow || 0}</div>
            <div className="text-gray-300 text-center">{trafego.leads_agendados > 0 ? ((trafego.leads_noshow / trafego.leads_agendados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{trafego.leads_calls || 0}</div>
            <div className="text-gray-300 text-center">{trafego.leads_agendados > 0 ? ((trafego.leads_calls / trafego.leads_agendados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{trafego.leads_ganhos || 0}</div>
            <div className="text-gray-300 text-center">{trafego.leads_calls > 0 ? ((trafego.leads_ganhos / trafego.leads_calls) * 100).toFixed(0) : 0}%</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{trafego.leads_perdidos || 0}</div>
            <div className={`text-center rounded px-1 font-bold ${
              trafegoTotal > 0 && (trafego.leads_ganhos / trafegoTotal) * 100 >= 5
                ? 'bg-green-500/20 border border-green-500 text-green-400'
                : 'bg-red-500/20 border border-red-500 text-red-400'
            }`}>
              {trafegoTotal > 0 ? ((trafego.leads_ganhos / trafegoTotal) * 100).toFixed(2) : 0}%
            </div>

            {/* BPO */}
            <div className="text-cyan-400 font-semibold">BPO</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpoTotal}</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpo.leads_qualificados || 0}</div>
            <div className="text-gray-300 text-center">{bpoTotal > 0 ? ((bpo.leads_qualificados / bpoTotal) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpo.leads_qualificados || 0}</div>
            <div className="text-gray-300 text-center">100%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpo.leads_agendados || 0}</div>
            <div className="text-gray-300 text-center">{bpo.leads_qualificados > 0 ? ((bpo.leads_agendados / bpo.leads_qualificados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{bpo.leads_noshow || 0}</div>
            <div className="text-gray-300 text-center">{bpo.leads_agendados > 0 ? ((bpo.leads_noshow / bpo.leads_agendados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpo.leads_calls || 0}</div>
            <div className="text-gray-300 text-center">{bpo.leads_agendados > 0 ? ((bpo.leads_calls / bpo.leads_agendados) * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpo.leads_ganhos || 0}</div>
            <div className="text-gray-300 text-center">{bpo.leads_calls > 0 ? ((bpo.leads_ganhos / bpo.leads_calls) * 100).toFixed(0) : 0}%</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{bpo.leads_perdidos || 0}</div>
            <div className={`text-center rounded px-1 font-bold ${
              bpoTotal > 0 && (bpo.leads_ganhos / bpoTotal) * 100 >= 5
                ? 'bg-green-500/20 border border-green-500 text-green-400'
                : 'bg-red-500/20 border border-red-500 text-red-400'
            }`}>
              {bpoTotal > 0 ? ((bpo.leads_ganhos / bpoTotal) * 100).toFixed(2) : 0}%
            </div>

            {/* TOTAL */}
            <div className="text-cyan-400 font-semibold">TOTAL</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{bpoTotal}</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{totalGeral}</div>
            <div className="text-gray-300 text-center">-</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{(trafego.leads_qualificados || 0) + (bpo.leads_qualificados || 0)}</div>
            <div className="text-gray-300 text-center">{totalGeral > 0 ? (((trafego.leads_qualificados || 0) + (bpo.leads_qualificados || 0)) / totalGeral * 100).toFixed(0) : 0}%</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{(trafego.leads_agendados || 0) + (bpo.leads_agendados || 0)}</div>
            <div className="text-gray-300 text-center">-</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{(trafego.leads_noshow || 0) + (bpo.leads_noshow || 0)}</div>
            <div className="text-gray-300 text-center">-</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{(trafego.leads_calls || 0) + (bpo.leads_calls || 0)}</div>
            <div className="text-gray-300 text-center">-</div>
            <div className="bg-blue-600 text-white font-bold text-center rounded px-1">{(trafego.leads_ganhos || 0) + (bpo.leads_ganhos || 0)}</div>
            <div className="text-gray-300 text-center">-</div>
            <div className="bg-orange-500 text-white font-bold text-center rounded px-1">{(trafego.leads_perdidos || 0) + (bpo.leads_perdidos || 0)}</div>
            <div className={`text-center rounded px-1 font-bold ${
              totalGeral > 0 && ((trafego.leads_ganhos || 0) + (bpo.leads_ganhos || 0)) / totalGeral * 100 >= 5
                ? 'bg-green-500/20 border border-green-500 text-green-400'
                : 'bg-red-500/20 border border-red-500 text-red-400'
            }`}>
              {totalGeral > 0 ? (((trafego.leads_ganhos || 0) + (bpo.leads_ganhos || 0)) / totalGeral * 100).toFixed(2) : 0}%
            </div>
          </div>
        </div>

        {/* Tabela mensal de métricas */}
        <div className="bg-slate-900/50 rounded-lg border border-slate-800 p-4">
          <h2 className="text-xl font-bold text-white mb-4">Métricas Mensais por Canal</h2>
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="text-xs text-gray-400 uppercase border-b border-slate-700">
                <tr>
                  <th className="py-3 px-4">Canal</th>
                  <th className="py-3 px-4">Mês</th>
                  <th className="py-3 px-4">Total Leads</th>
                  <th className="py-3 px-4">Qualificados</th>
                  <th className="py-3 px-4">Agendados</th>
                  <th className="py-3 px-4">Calls</th>
                  <th className="py-3 px-4">Ganhos</th>
                  <th className="py-3 px-4">Taxa Conv.</th>
                </tr>
              </thead>
              <tbody>
                {metricas.map((m, idx) => (
                  <tr key={idx} className="border-b border-slate-800 hover:bg-slate-800/30">
                    <td className="py-3 px-4 text-cyan-400 font-semibold">{m.canal}</td>
                    <td className="py-3 px-4 text-white">{m.mes}/{m.ano}</td>
                    <td className="py-3 px-4 text-white">{m.total_leads}</td>
                    <td className="py-3 px-4 text-white">{m.leads_qualificados}</td>
                    <td className="py-3 px-4 text-white">{m.leads_agendados}</td>
                    <td className="py-3 px-4 text-white">{m.leads_calls}</td>
                    <td className="py-3 px-4 text-white">{m.leads_ganhos}</td>
                    <td className="py-3 px-4">
                      <span className={`font-bold ${
                        m.taxa_conversao >= 5
                          ? 'text-green-400'
                          : 'text-red-400'
                      }`}>
                        {m.taxa_conversao.toFixed(2)}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  )
}
