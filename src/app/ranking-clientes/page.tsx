'use client';

import Sidebar from '@/components/Sidebar';

const rankingClientes = [
  { rank: 1, cliente: 'Andre Rosa', leadQualif: 796, txConv: '36%', leadsAgend: 288 },
  { rank: 2, cliente: 'Taci e Marcos', leadQualif: 395, txConv: '34%', leadsAgend: 136 },
  { rank: 3, cliente: 'Aline Morais', leadQualif: 714, txConv: '17%', leadsAgend: 124 },
  { rank: 4, cliente: 'Fernanda Lappe', leadQualif: 572, txConv: '14%', leadsAgend: 82 },
  { rank: 5, cliente: 'Gladson Almeida', leadQualif: 276, txConv: '16%', leadsAgend: 44 },
  { rank: 6, cliente: 'Matheus Dias', leadQualif: 234, txConv: '17%', leadsAgend: 40 },
  { rank: 7, cliente: 'Milton', leadQualif: 138, txConv: '27%', leadsAgend: 37 },
  { rank: 8, cliente: 'Greg e Ana', leadQualif: 131, txConv: '18%', leadsAgend: 24 },
  { rank: 9, cliente: 'Juliana Costa', leadQualif: 196, txConv: '11%', leadsAgend: 22 },
  { rank: 10, cliente: 'Kamilla Cavalcanti', leadQualif: 161, txConv: '7%', leadsAgend: 12 },
];

export default function RankingClientesPage() {
  const top3 = rankingClientes.slice(0, 3);

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />

      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          <h1 className="text-2xl font-light">
            <span className="text-white">Ranking</span>{' '}
            <span className="text-cyan-400">Clientes</span>
          </h1>

          {/* Podium */}
          <div className="bg-slate-900/50 rounded-xl p-8 border border-slate-800">
            <div className="flex items-end justify-center gap-6 mb-8">
              {/* 2nd Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[1]?.cliente}</span>
                <span className="text-cyan-400 text-lg font-bold mb-2">{top3[1]?.leadsAgend} agend</span>
                <div className="bg-gradient-to-t from-blue-700 to-blue-500 w-32 h-36 rounded-t-lg flex items-center justify-center">
                  <span className="text-4xl font-bold text-white/80">②</span>
                </div>
              </div>
              
              {/* 1st Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[0]?.cliente}</span>
                <span className="text-yellow-400 text-lg font-bold mb-2">{top3[0]?.leadsAgend} agend</span>
                <div className="bg-gradient-to-t from-blue-600 to-blue-400 w-32 h-48 rounded-t-lg flex items-center justify-center">
                  <span className="text-5xl font-bold text-white">①</span>
                </div>
              </div>
              
              {/* 3rd Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[2]?.cliente}</span>
                <span className="text-orange-400 text-lg font-bold mb-2">{top3[2]?.leadsAgend} agend</span>
                <div className="bg-gradient-to-t from-blue-800 to-blue-600 w-32 h-28 rounded-t-lg flex items-center justify-center">
                  <span className="text-3xl font-bold text-white/60">③</span>
                </div>
              </div>
            </div>
          </div>

          {/* Tabela Completa */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            <h3 className="text-gray-300 text-sm font-semibold mb-4">Ranking por Leads Agendados</h3>
            <table className="w-full text-sm">
              <thead>
                <tr className="text-gray-400 border-b border-slate-700">
                  <th className="text-left py-2 px-3">Posição</th>
                  <th className="text-left py-2 px-3">Cliente</th>
                  <th className="text-right py-2 px-3">Lead Qualif</th>
                  <th className="text-right py-2 px-3">Tx Conv</th>
                  <th className="text-right py-2 px-3">Leads Agend</th>
                </tr>
              </thead>
              <tbody>
                {rankingClientes.map((item) => (
                  <tr 
                    key={item.rank} 
                    className={`text-white border-b border-slate-800 hover:bg-slate-800/30 ${
                      item.rank <= 3 ? 'bg-blue-900/20' : ''
                    }`}
                  >
                    <td className="py-3 px-3">
                      {item.rank <= 3 ? (
                        <span className={`inline-flex items-center justify-center w-8 h-8 rounded-full font-bold ${
                          item.rank === 1 ? 'bg-yellow-500 text-black' :
                          item.rank === 2 ? 'bg-gray-300 text-black' :
                          'bg-orange-600 text-white'
                        }`}>
                          {item.rank}
                        </span>
                      ) : (
                        <span className="text-gray-400 pl-2">{item.rank}º</span>
                      )}
                    </td>
                    <td className="py-3 px-3 text-cyan-400 font-medium">{item.cliente}</td>
                    <td className="py-3 px-3 text-right">{item.leadQualif}</td>
                    <td className="py-3 px-3 text-right">
                      <span className={`px-2 py-1 rounded text-xs font-bold ${
                        parseInt(item.txConv) >= 30 ? 'bg-green-500/20 text-green-400' :
                        parseInt(item.txConv) >= 15 ? 'bg-yellow-500/20 text-yellow-400' :
                        'bg-red-500/20 text-red-400'
                      }`}>
                        {item.txConv}
                      </span>
                    </td>
                    <td className="py-3 px-3 text-right font-bold text-lg">{item.leadsAgend}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-gradient-to-br from-blue-900/80 to-blue-950/80 rounded-xl p-6 text-center border border-blue-800/50">
              <p className="text-gray-300 text-sm mb-2">Total Leads Qualif</p>
              <p className="text-4xl font-bold text-white">3.613</p>
            </div>
            <div className="bg-gradient-to-br from-cyan-900/80 to-cyan-950/80 rounded-xl p-6 text-center border border-cyan-800/50">
              <p className="text-gray-300 text-sm mb-2">Total Leads Agend</p>
              <p className="text-4xl font-bold text-cyan-400">809</p>
            </div>
            <div className="bg-gradient-to-br from-green-900/80 to-green-950/80 rounded-xl p-6 text-center border border-green-800/50">
              <p className="text-gray-300 text-sm mb-2">Média Tx Conv</p>
              <p className="text-4xl font-bold text-green-400">19,7%</p>
            </div>
            <div className="bg-gradient-to-br from-orange-900/80 to-orange-950/80 rounded-xl p-6 text-center border border-orange-800/50">
              <p className="text-gray-300 text-sm mb-2">Clientes Ativos</p>
              <p className="text-4xl font-bold text-orange-400">10</p>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
