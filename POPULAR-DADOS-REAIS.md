# 🎯 POPULAR DASHBOARD COM DADOS REAIS DO SUPABASE

O dashboard está **100% pronto visualmente**! ✅
Agora vamos conectar com dados reais do Supabase em 2 etapas simples.

---

## 📋 ETAPA 1: Executar Scripts SQL no Supabase

### 1.1 - Acessar SQL Editor do Supabase

🔗 **Link direto:** https://supabase.com/dashboard/project/bfumywvwubvernvhjehk/sql/new

### 1.2 - Executar 4 Scripts na Ordem

Execute cada script **um de cada vez**, aguardando a confirmação de sucesso antes do próximo.

---

#### ✅ SCRIPT 1: Dashboard Principal (Home - Funil TRÁFEGO/BPO/TOTAL)

📁 **Arquivo:** `scripts/create-powerbi-dashboard-metrics.sql`

**Como executar:**
1. Abra o arquivo `scripts/create-powerbi-dashboard-metrics.sql`
2. Copie **TODO** o conteúdo (Cmd+A, Cmd+C)
3. Cole no SQL Editor do Supabase
4. Clique em **"RUN"** ou pressione Cmd+Enter
5. Aguarde mensagem: `✅ View powerbi_dashboard_metrics criada!`

**O que faz:**
- Cria view `public.powerbi_dashboard_metrics`
- Retorna 1 linha com todas as métricas do funil (TRÁFEGO/BPO/TOTAL)
- Campos: leads_traf, leads_qualif_traf, leads_otb, leads_total, taxas, etc.

---

#### ✅ SCRIPT 2: Métricas Mensais (Tabela Histórica)

📁 **Arquivo:** `scripts/create-monthly-metrics-view.sql`

**Como executar:**
1. Abra o arquivo `scripts/create-monthly-metrics-view.sql`
2. Copie **TODO** o conteúdo
3. Cole no SQL Editor do Supabase
4. Clique em **"RUN"**
5. Aguarde mensagem: `✅ View monthly_metrics criada!`

**O que faz:**
- Cria view `public.monthly_metrics`
- Retorna dados agrupados por mês (Jan, Fev, Mar, etc.)
- 30+ campos incluindo investimentos, SAL, agendados, calls, ganhos, CPAs

---

#### ✅ SCRIPT 3: Ranking de Clientes

📁 **Arquivo:** `scripts/create-client-ranking-view.sql`

**Como executar:**
1. Abra o arquivo `scripts/create-client-ranking-view.sql`
2. Copie **TODO** o conteúdo
3. Cole no SQL Editor do Supabase
4. Clique em **"RUN"**
5. Aguarde mensagem: `✅ View client_ranking criada!`

**O que faz:**
- Cria view `public.client_ranking`
- Retorna TOP 10 clientes ordenados por leads agendados
- Campos: rank, cliente, leadQualif, txConv, leadsAgend

---

#### ✅ SCRIPT 4: Detalhes de Clientes

📁 **Arquivo:** `scripts/create-client-details-view.sql`

**Como executar:**
1. Abra o arquivo `scripts/create-client-details-view.sql`
2. Copie **TODO** o conteúdo
3. Cole no SQL Editor do Supabase
4. Clique em **"RUN"**
5. Aguarde mensagem: `✅ View client_details criada!`

**O que faz:**
- Cria view `public.client_details`
- Retorna métricas completas por cliente (22+ campos)
- Campos: cliente, invTraf, invBpo, ativados, leadQualif, calls, ganhos, etc.

---

### 1.3 - Verificar se Deu Certo

Após executar os 4 scripts, teste no SQL Editor:

```sql
-- Teste 1: Dashboard principal (deve retornar 1 linha)
SELECT
  leads_traf,
  leads_otb,
  leads_total,
  taxa_conv_total
FROM public.powerbi_dashboard_metrics;

-- Teste 2: Métricas mensais (deve retornar várias linhas)
SELECT mes, sal, leads_agd, tt_calls
FROM public.monthly_metrics
LIMIT 5;

-- Teste 3: Ranking clientes (deve retornar TOP 10)
SELECT rank, cliente, leadsAgend
FROM public.client_ranking
LIMIT 5;

-- Teste 4: Detalhes clientes (deve retornar todos)
SELECT cliente, ativados, leadQualif, calls
FROM public.client_details
LIMIT 5;
```

Se todas retornarem dados ✅, prossiga para Etapa 2!

---

## 📋 ETAPA 2: Atualizar Código para Usar Dados Reais

### 2.1 - Configurar Credenciais do Supabase

Se ainda não configurou, crie o arquivo `.env.local`:

```bash
# No diretório do projeto
cd /Users/marcosdaniels/sales-dashboard/sales-dashboard/mottivme-dashboard-nextjs

# Copiar exemplo
cp .env.example .env.local

# Editar com suas credenciais
# Adicione:
NEXT_PUBLIC_SUPABASE_URL=https://bfumywvwubvernvhjehk.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_anon_key_aqui
```

**Onde encontrar a ANON_KEY:**
1. Acesse: https://supabase.com/dashboard/project/bfumywvwubvernvhjehk/settings/api
2. Copie o valor de **"anon public"**

---

### 2.2 - Atualizar Página Home (src/app/page.tsx)

**Substituir linhas 50-53:**

De:
```typescript
const [metrics, setMetrics] = useState<DashboardMetrics>(mockMetrics);
const [monthlyData, setMonthlyData] = useState<MonthlyData[]>(mockMonthlyData);
const [loading, setLoading] = useState(false);
```

Para:
```typescript
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
    } else if (metricsData) {
      setMetrics(metricsData);
    }

    // Buscar dados mensais
    const { data: monthlyDataResult, error: monthlyError } = await supabase
      .from('monthly_metrics')
      .select('*')
      .order('mes', { ascending: true });

    if (monthlyError) {
      console.error('Erro ao buscar dados mensais:', monthlyError);
    } else if (monthlyDataResult) {
      setMonthlyData(monthlyDataResult);
    }
  } catch (error) {
    console.error('Erro:', error);
  } finally {
    setLoading(false);
  }
};
```

**E adicionar import do supabase no topo:**
```typescript
import { supabase } from '@/lib/supabase';
```

---

### 2.3 - Atualizar Outras Páginas (Opcional)

Se você tiver outras páginas (Usuários, Evolução, Rankings), atualize também:

#### Página Usuários (src/app/usuarios/page.tsx)
```typescript
const { data, error } = await supabase
  .from('client_details')
  .select('*');
```

#### Página Evolução (src/app/evolucao/page.tsx)
```typescript
const { data, error } = await supabase
  .from('monthly_metrics')
  .select('*')
  .order('mes', { ascending: true });
```

#### Página Ranking Clientes (src/app/ranking-clientes/page.tsx)
```typescript
const { data, error } = await supabase
  .from('client_ranking')
  .select('*');
```

---

## ✅ VERIFICAR SE ESTÁ FUNCIONANDO

1. Reinicie o servidor de desenvolvimento:
```bash
npm run dev
```

2. Acesse: http://localhost:3000

3. Verifique se:
   - ✅ Funil TRÁFEGO/BPO/TOTAL mostra números reais (não mockados)
   - ✅ Tabela histórica mostra dados mensais do Supabase
   - ✅ Console do navegador (F12) não mostra erros

---

## 🐛 TROUBLESHOOTING

### Erro: "relation does not exist"
**Solução:** Execute os scripts SQL novamente no Supabase

### Erro: "Invalid API key"
**Solução:** Verifique se o arquivo `.env.local` tem as credenciais corretas

### Dados não aparecem
**Solução 1:** Verifique se as views retornam dados no SQL Editor do Supabase
**Solução 2:** Abra o Console do navegador (F12 > Console) e veja se há erros

### Tipos TypeScript não batem
**Solução:** Verifique se o arquivo `src/types/index.ts` tem as interfaces corretas

---

## 📊 CAMPOS DISPONÍVEIS

### DashboardMetrics (powerbi_dashboard_metrics)
```typescript
{
  leads_traf: number;
  leads_qualif_traf: number;
  leads_agend_traf: number;
  leads_noshow_traf: number;
  calls_traf: number;
  leads_venda_traf: number;
  leads_desqualif_traf: number;
  pct_leads_qualif_traf: number;
  pct_qualif_agend_traf: number;
  pct_agend_calls_traf: number;
  pct_calls_venda_traf: number;
  prospec_otb: number;
  leads_otb: number;
  leads_qualif_otb: number;
  leads_agend_otb: number;
  leads_noshow_otb: number;
  calls_otb: number;
  leads_venda_otb: number;
  leads_desqualif_otb: number;
  pct_leads_qualif_otb: number;
  pct_qualif_agend_otb: number;
  pct_agend_calls_otb: number;
  pct_calls_venda_otb: number;
  leads_total: number;
  leads_qualif_total: number;
  leads_agend_total: number;
  calls_total: number;
  leads_venda_total: number;
  noshow_total: number;
  perdido_total: number;
  taxa_conv_total: number;
  pct_leads_qualif_total: number;
}
```

### MonthlyData (monthly_metrics)
```typescript
{
  mes: string;
  inv_trafego: number;
  inv_bpo: number;
  sal: number;
  pct_agd: number;
  leads_agd: number;
  pct_calls: number;
  tt_calls: number;
  pct_ganhos: number;
  tt_ganhos: number;
  tl_agd_traf: number;
  tl_agd_bpo: number;
  calls_traf: number;
  calls_bpo: number;
  ganhos_traf: number;
  ganhos_bpo: number;
  cpl_traf: number;
  cpl_bpo: number;
  cpra_traf: number;
  cpra_bpo: number;
  cpa_traf: number;
  cpa_bpo: number;
}
```

---

## 🎯 RESULTADO ESPERADO

Após completar as 2 etapas:

✅ **Dashboard Home**
- Funil TRÁFEGO/BPO/TOTAL com dados reais agregados
- Tabela histórica com meses reais (Jan, Fev, Mar, etc.)
- Valores dinâmicos atualizados do Supabase

✅ **Sem Mock Data**
- Todos os dados vêm do Supabase
- Atualização automática quando dados mudam

✅ **Pronto para Produção**
- Deploy no Vercel funcionará perfeitamente
- Apenas configure as mesmas env vars no Vercel

---

**🚀 Execute agora e seu dashboard estará 100% com dados reais!**
