# MOTTIVME Sales Dashboard

Dashboard de vendas completo em Next.js 14 com tema escuro, métricas de funil e rankings.

## 🚀 Tecnologias

- **Next.js 14** - App Router
- **TypeScript** - Tipagem estática
- **Tailwind CSS** - Estilização
- **Recharts** - Gráficos
- **Lucide React** - Ícones
- **Supabase** - Backend (opcional)

## 📁 Estrutura do Projeto

```
src/
├── app/
│   ├── globals.css          # Estilos globais
│   ├── layout.tsx           # Layout principal
│   ├── page.tsx             # Home - Overview Comercial
│   ├── usuarios/
│   │   └── page.tsx         # Página de Usuários
│   ├── evolucao/
│   │   └── page.tsx         # Evolução Mensal (gráficos)
│   ├── ranking-mottivados/
│   │   └── page.tsx         # Ranking Mottivados
│   └── ranking-clientes/
│       └── page.tsx         # Ranking Clientes
├── components/
│   └── Sidebar.tsx          # Menu lateral
├── lib/
│   └── supabase.ts          # Cliente Supabase
└── types/
    └── index.ts             # Tipos TypeScript
```

## 🛠️ Instalação

```bash
# 1. Instalar dependências
npm install

# 2. Copiar arquivo de ambiente
cp .env.example .env.local

# 3. Configurar variáveis (opcional - para Supabase)
# Edite .env.local com suas credenciais

# 4. Iniciar servidor de desenvolvimento
npm run dev
```

## 🎨 Páginas Implementadas

### Home (Overview Comercial)
- Funil de métricas TRÁFEGO / BPO / TOTAL
- Tabela mensal com 22 colunas e scroll horizontal
- Sticky column na primeira coluna

### Usuários
- Mesmo funil de métricas
- Tabela por usuário com todas as métricas

### Evolução
- 4 gráficos de barras (Recharts)
- Leads Qualificados, Taxa Conversão, Leads Agendados, CPA

### Ranking Mottivados
- Pódio visual (top 3)
- Tabela completa com badges de posição

### Ranking Clientes
- Pódio visual (top 3)
- Tabela com indicadores coloridos de taxa de conversão

## 🎯 Especificações Técnicas Críticas

### Grid do Funil (17 colunas)
```tsx
grid-cols-[100px_repeat(16,1fr)]
```

### Cores Padrão
- **Valores numéricos**: `bg-blue-600` ou `bg-orange-500`
- **Percentuais**: `text-gray-300` (apenas texto)
- **Tx Conv positiva**: `bg-green-500/20 border-green-500 text-green-400`
- **Tx Conv negativa**: `bg-red-500/20 border-red-500 text-red-400`
- **Valores Tráfego**: `text-green-400`
- **Valores BPO**: `text-orange-400`

### Tabela com Scroll
```tsx
<div className="overflow-x-auto">
  <table className="text-sm whitespace-nowrap w-full">
    <thead>
      <tr>
        <th className="sticky left-0 bg-slate-900 z-10">...</th>
      </tr>
    </thead>
  </table>
</div>
```

## 🔗 Integração Supabase (Opcional)

### Configurar variáveis de ambiente
```env
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-aqui
```

## ⚠️ Regras Importantes (NÃO MODIFICAR)

1. **Grid 17 colunas**: `grid-cols-[100px_repeat(16,1fr)]` - NUNCA mudar
2. **Caracteres UTF-8**: TRÁFEGO (não TRÃFEGO), ▶ (não â–¶)
3. **Sidebar fixa**: `ml-[230px]` no main
4. **Cores do tema**: slate-950, slate-900, blue-600, orange-500
5. **Primeira coluna sticky**: `sticky left-0 bg-slate-900 z-10`

## 📦 Deploy

```bash
# Build para produção
npm run build

# Iniciar em produção
npm start
```

### Vercel (Recomendado)
1. Push para GitHub
2. Conectar repositório no Vercel
3. Configurar variáveis de ambiente
4. Deploy automático

---

**MOTTIVME Sales Dashboard** - Desenvolvido com ❤️
