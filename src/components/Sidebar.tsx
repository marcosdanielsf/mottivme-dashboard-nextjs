'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, Users, TrendingUp, Trophy, Building2, ChevronDown } from 'lucide-react';

interface MenuItem {
  label: string;
  href: string;
  icon: React.ReactNode;
}

const menuItems: MenuItem[] = [
  { label: 'Home', href: '/', icon: <Home className="w-4 h-4" /> },
  { label: 'Usuários', href: '/usuarios', icon: <Users className="w-4 h-4" /> },
  { label: 'Evolução', href: '/evolucao', icon: <TrendingUp className="w-4 h-4" /> },
  { label: 'Ranking Mottivados', href: '/ranking-mottivados', icon: <Trophy className="w-4 h-4" /> },
  { label: 'Ranking Clientes', href: '/ranking-clientes', icon: <Building2 className="w-4 h-4" /> },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed left-0 top-0 h-screen w-[230px] bg-slate-950/90 border-r border-slate-800 flex flex-col z-50">
      {/* Logo */}
      <div className="p-6 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-400 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-lg">M</span>
          </div>
          <div>
            <h1 className="text-white font-bold text-lg">MOTTIVME</h1>
            <p className="text-gray-400 text-xs">Sales Dashboard</p>
          </div>
        </div>
      </div>

      {/* Menu Navigation */}
      <nav className="flex-1 p-4">
        <ul className="space-y-1">
          {menuItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm transition-all ${
                    isActive
                      ? 'bg-blue-600/20 text-cyan-400 border-l-2 border-cyan-400'
                      : 'text-gray-400 hover:bg-slate-800/50 hover:text-white'
                  }`}
                >
                  {item.icon}
                  {item.label}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Filters Section */}
      <div className="p-4 border-t border-slate-800">
        <p className="text-gray-500 text-xs uppercase tracking-wide mb-3">Filtros</p>
        
        {/* Mês Filter */}
        <div className="mb-3">
          <label className="text-gray-400 text-xs mb-1 block">Mês</label>
          <div className="relative">
            <select className="w-full bg-slate-800/50 border border-slate-700 rounded-lg px-3 py-2 text-cyan-400 text-sm appearance-none cursor-pointer focus:outline-none focus:border-blue-500">
              <option>Janeiro</option>
              <option>Fevereiro</option>
              <option>Março</option>
              <option>Abril</option>
              <option>Maio</option>
              <option>Junho</option>
              <option>Julho</option>
              <option>Agosto</option>
              <option>Setembro</option>
              <option>Outubro</option>
              <option>Novembro</option>
              <option>Dezembro</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
          </div>
        </div>

        {/* Ano Filter */}
        <div className="mb-3">
          <label className="text-gray-400 text-xs mb-1 block">Ano</label>
          <div className="relative">
            <select className="w-full bg-slate-800/50 border border-slate-700 rounded-lg px-3 py-2 text-cyan-400 text-sm appearance-none cursor-pointer focus:outline-none focus:border-blue-500">
              <option>2024</option>
              <option>2025</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
          </div>
        </div>

        {/* Cliente Filter */}
        <div className="mb-3">
          <label className="text-gray-400 text-xs mb-1 block">Cliente</label>
          <div className="relative">
            <select className="w-full bg-slate-800/50 border border-slate-700 rounded-lg px-3 py-2 text-cyan-400 text-sm appearance-none cursor-pointer focus:outline-none focus:border-blue-500">
              <option>Todos</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
          </div>
        </div>

        {/* Fonte do Lead Filter */}
        <div>
          <label className="text-gray-400 text-xs mb-1 block">Fonte do Lead</label>
          <div className="relative">
            <select className="w-full bg-slate-800/50 border border-slate-700 rounded-lg px-3 py-2 text-cyan-400 text-sm appearance-none cursor-pointer focus:outline-none focus:border-blue-500">
              <option>Todos</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
          </div>
        </div>
      </div>

      {/* Version */}
      <div className="p-4 border-t border-slate-800">
        <p className="text-gray-600 text-xs">v1.0.0 | 2025</p>
      </div>
    </aside>
  );
}
