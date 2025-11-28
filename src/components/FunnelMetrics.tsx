'use client';

interface FunnelRow {
  label: string;
  labelColor: string;
  prospec: number | string;
  lead: number;
  pctLead: number;
  qualif: number;
  pctQualif: number;
  agend: number;
  pctAgend: number;
  noshow: number;
  pctNoshow: number;
  calls: number;
  pctCalls: number;
  ganho: number;
  pctGanho: number | string;
  perdido: number;
  txConv: number | string;
  txConvColor: 'green' | 'red';
}

interface FunnelMetricsProps {
  trafego: FunnelRow;
  bpo: FunnelRow;
  total: FunnelRow;
}

export default function FunnelMetrics({ trafego, bpo, total }: FunnelMetricsProps) {
  const renderRow = (row: FunnelRow, isTotal: boolean = false) => (
    <div className={`grid grid-cols-[100px_repeat(16,1fr)] gap-1 items-center ${isTotal ? 'border-t border-slate-700 pt-2' : 'mb-2'}`}>
      <div className="flex items-center gap-1">
        <span className={`font-semibold text-sm ${row.labelColor}`}>{row.label}</span>
        <span className="text-gray-500">▶</span>
      </div>
      
      {row.prospec === '—' ? (
        <div className="text-center text-gray-500">—</div>
      ) : (
        <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">
          {typeof row.prospec === 'number' ? row.prospec.toLocaleString('pt-BR') : row.prospec}
        </div>
      )}
      
      <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.lead.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">{row.pctLead}%</div>
      
      <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.qualif.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">{row.pctQualif}%</div>
      
      <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.agend.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">{row.pctAgend}%</div>
      
      <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.noshow.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">{row.pctNoshow}%</div>
      
      <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.calls.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">{row.pctCalls}%</div>
      
      <div className="bg-blue-600 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.ganho.toLocaleString('pt-BR')}
      </div>
      <div className="text-center text-gray-300 text-sm">
        {row.pctGanho === '—' ? '—' : `${row.pctGanho}%`}
      </div>
      
      <div className="bg-orange-500 rounded px-2 py-1 text-center text-white font-bold text-sm">
        {row.perdido.toLocaleString('pt-BR')}
      </div>
      
      <div className={`rounded px-2 py-1 text-center font-bold text-sm ${
        row.txConvColor === 'green' 
          ? 'bg-green-500/20 border border-green-500 text-green-400'
          : 'bg-red-500/20 border border-red-500 text-red-400'
      }`}>
        {typeof row.txConv === 'number' ? `${row.txConv}%` : row.txConv}
      </div>
    </div>
  );

  return (
    <div className="bg-slate-900/50 rounded-xl p-4 border border-slate-800">
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

      {renderRow(trafego)}
      {renderRow(bpo)}
      {renderRow(total, true)}
    </div>
  );
}
