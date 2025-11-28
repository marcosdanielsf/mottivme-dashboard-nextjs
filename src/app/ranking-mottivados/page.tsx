'use client';

import Sidebar from '@/components/Sidebar';

const rankingMottivados = [
  { rank: 1, nome: 'Isabella', leads: 320 },
  { rank: 2, nome: 'Vanessa Sanches', leads: 238 },
  { rank: 3, nome: '(Em branco)', leads: 85 },
  { rank: 4, nome: 'Gabrielle Lamarca', leads: 37 },
  { rank: 5, nome: 'Marcos Daniel', leads: 31 },
  { rank: 6, nome: 'Isabella Delduco', leads: 28 },
  { rank: 7, nome: 'João Gabriel', leads: 18 },
  { rank: 8, nome: 'Greg e Ana', leads: 14 },
  { rank: 9, nome: 'Glaucio', leads: 12 },
  { rank: 10, nome: 'I.A', leads: 11 },
];

export default function RankingMottivadosPage() {
  const top3 = rankingMottivados.slice(0, 3);
  const rest = rankingMottivados.slice(3);

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Sidebar />

      <main className="flex-1 ml-[230px] overflow-y-auto p-8">
        <div className="space-y-6">
          <h1 className="text-2xl font-light">
            <span className="text-white">Ranking</span>{' '}
            <span className="text-cyan-400">Mottivados</span>
          </h1>

          {/* Podium */}
          <div className="bg-slate-900/50 rounded-xl p-8 border border-slate-800">
            <div className="flex items-end justify-center gap-6 mb-8">
              {/* 2nd Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[1]?.nome}</span>
                <span className="text-cyan-400 text-lg font-bold mb-2">{top3[1]?.leads} leads</span>
                <div className="bg-gradient-to-t from-blue-700 to-blue-500 w-32 h-36 rounded-t-lg flex items-center justify-center">
                  <span className="text-4xl font-bold text-white/80">②</span>
                </div>
              </div>
              
              {/* 1st Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[0]?.nome}</span>
                <span className="text-yellow-400 text-lg font-bold mb-2">{top3[0]?.leads} leads</span>
                <div className="bg-gradient-to-t from-blue-600 to-blue-400 w-32 h-48 rounded-t-lg flex items-center justify-center">
                  <span className="text-5xl font-bold text-white">①</span>
                </div>
              </div>
              
              {/* 3rd Place */}
              <div className="flex flex-col items-center">
                <span className="text-white font-semibold text-sm mb-2 text-center">{top3[2]?.nome}</span>
                <span className="text-orange-400 text-lg font-bold mb-2">{top3[2]?.leads} leads</span>
                <div className="bg-gradient-to-t from-blue-800 to-blue-600 w-32 h-28 rounded-t-lg flex items-center justify-center">
                  <span className="text-3xl font-bold text-white/60">③</span>
                </div>
              </div>
            </div>
          </div>

          {/* Tabela Completa */}
          <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
            <h3 className="text-gray-300 text-sm font-semibold mb-4">Ranking Completo</h3>
            <table className="w-full text-sm">
              <thead>
                <tr className="text-gray-400 border-b border-slate-700">
                  <th className="text-left py-2 px-3">Posição</th>
                  <th className="text-left py-2 px-3">Nome</th>
                  <th className="text-right py-2 px-3">Leads Qualificados</th>
                </tr>
              </thead>
              <tbody>
                {rankingMottivados.map((item) => (
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
                    <td className="py-3 px-3 text-cyan-400 font-medium">{item.nome}</td>
                    <td className="py-3 px-3 text-right font-bold text-lg">{item.leads}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-gradient-to-br from-blue-900/80 to-blue-950/80 rounded-xl p-6 text-center border border-blue-800/50">
              <p className="text-gray-300 text-sm mb-2">Total de Leads</p>
              <p className="text-4xl font-bold text-white">794</p>
            </div>
            <div className="bg-gradient-to-br from-cyan-900/80 to-cyan-950/80 rounded-xl p-6 text-center border border-cyan-800/50">
              <p className="text-gray-300 text-sm mb-2">Média por Mottivado</p>
              <p className="text-4xl font-bold text-cyan-400">79,4</p>
            </div>
            <div className="bg-gradient-to-br from-green-900/80 to-green-950/80 rounded-xl p-6 text-center border border-green-800/50">
              <p className="text-gray-300 text-sm mb-2">Top 3 Total</p>
              <p className="text-4xl font-bold text-green-400">643</p>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
