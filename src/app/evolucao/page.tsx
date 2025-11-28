'use client';

import { useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const monthlyData = [
  { month: 'Jan', leadQualif: 146, txConv: 32, leadsAgend: 47, cpaTraf: 46, cpaBpo: 53, otb: 19, traf: 28 },
  { month: 'Fev', leadQualif: 177, txConv: 39, leadsAgend: 69, cpaTraf: 25, cpaBpo: 56, otb: 18, traf: 51 },
  { month: 'Mar', leadQualif: 83, txConv: 37, leadsAgend: 31, cpaTraf: 56, cpaBpo: 167, otb: 6, traf: 25 },
  { month: 'Abr', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Mai', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Jun', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Jul', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Ago', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Set', leadQualif: 0, txConv: 0, leadsAgend: 0, cpaTraf: 0, cpaBpo: 0, otb: 0, traf: 0 },
  { month: 'Out', leadQualif: 148, txConv: 16, leadsAgend: 31, cpaTraf: 0, cpaBpo: 0, otb: 5, traf: 15 },
  { month: 'Nov', leadQualif: 115, txConv: 20, leadsAgend: 29, cpaTraf: 79, cpaBpo: 76, otb: 14, traf: 29 },
  { month: 'Dez', leadQualif: 0, txConv: 23, leadsAgend: 27, cpaTraf: 67, cpaBpo: 100, otb: 10, traf: 17 },
];

export default function EvolucaoPage() {
  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />

      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          <h1 className="text-2xl font-light">
            <span className="text-white">Evolução</span>{' '}
            <span className="text-cyan-400">Mensal</span>
          </h1>

          {/* Grid de Gráficos */}
          <div className="grid grid-cols-2 gap-6">
            {/* Leads Qualificados */}
            <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
              <h3 className="text-gray-300 text-sm font-semibold mb-4">Leads Qualificados por Mês</h3>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                  <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
                  <YAxis stroke="#94a3b8" fontSize={12} />
                  <Tooltip contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: '8px' }} />
                  <Bar dataKey="leadQualif" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* Taxa de Conversão */}
            <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
              <h3 className="text-gray-300 text-sm font-semibold mb-4">Taxa de Conversão (%)</h3>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                  <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
                  <YAxis stroke="#94a3b8" fontSize={12} />
                  <Tooltip contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: '8px' }} />
                  <Bar dataKey="txConv" fill="#22c55e" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* Leads Agendados */}
            <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
              <h3 className="text-gray-300 text-sm font-semibold mb-4">Leads Agendados (OTB vs TRAF)</h3>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                  <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
                  <YAxis stroke="#94a3b8" fontSize={12} />
                  <Tooltip contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: '8px' }} />
                  <Legend />
                  <Bar dataKey="otb" name="OTB" fill="#3b82f6" stackId="a" radius={[0, 0, 0, 0]} />
                  <Bar dataKey="traf" name="TRAF" fill="#1e3a5f" stackId="a" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* CPA por Canal */}
            <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
              <h3 className="text-gray-300 text-sm font-semibold mb-4">CPA por Canal (R$)</h3>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                  <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
                  <YAxis stroke="#94a3b8" fontSize={12} />
                  <Tooltip contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: '8px' }} />
                  <Legend />
                  <Bar dataKey="cpaTraf" name="CPA TRAF" fill="#22c55e" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="cpaBpo" name="CPA BPO" fill="#f97316" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Resumo */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-gradient-to-br from-blue-900/80 to-blue-950/80 rounded-xl p-6 text-center border border-blue-800/50">
              <p className="text-gray-300 text-sm mb-2">Total Leads Qualif</p>
              <p className="text-4xl font-bold text-white">669</p>
            </div>
            <div className="bg-gradient-to-br from-green-900/80 to-green-950/80 rounded-xl p-6 text-center border border-green-800/50">
              <p className="text-gray-300 text-sm mb-2">Média Tx Conversão</p>
              <p className="text-4xl font-bold text-green-400">28%</p>
            </div>
            <div className="bg-gradient-to-br from-cyan-900/80 to-cyan-950/80 rounded-xl p-6 text-center border border-cyan-800/50">
              <p className="text-gray-300 text-sm mb-2">Total Leads Agend</p>
              <p className="text-4xl font-bold text-cyan-400">234</p>
            </div>
            <div className="bg-gradient-to-br from-orange-900/80 to-orange-950/80 rounded-xl p-6 text-center border border-orange-800/50">
              <p className="text-gray-300 text-sm mb-2">CPA Médio</p>
              <p className="text-4xl font-bold text-orange-400">R$ 67</p>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
