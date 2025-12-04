# 🎨 Mottivme Design System

Sistema de design padronizado para todos os projetos Mottivme. Este guia garante consistência visual em landing pages, dashboards, aplicações e materiais de marketing.

---

## 📋 Índice

1. [Cores](#cores)
2. [Tipografia](#tipografia)
3. [Componentes](#componentes)
4. [Variações](#variacoes)
5. [Como Usar](#como-usar)
6. [Exemplos](#exemplos)

---

## 🎨 Cores

### Paleta Principal

```css
/* Background Dark (Fundo Principal) */
--mottivme-dark: #0B0F19

/* Azul Mottivme (Cor da Marca) */
--mottivme-blue: #3B82F6

/* Azul Escuro (Botões e CTAs) */
--mottivme-blue-dark: #2563EB

/* Texto Primário */
--mottivme-text-primary: #FFFFFF

/* Texto Secundário */
--mottivme-text-secondary: #D1D5DB
```

### Escala de Azul Completa

| Nome | Hex | Uso |
|------|-----|-----|
| `primary-50` | `#eff6ff` | Backgrounds claros |
| `primary-100` | `#dbeafe` | Hover states light |
| `primary-200` | `#bfdbfe` | Borders light |
| `primary-300` | `#93c5fd` | Disabled states |
| `primary-400` | `#60a5fa` | Secondary buttons |
| `primary-500` | `#3B82F6` | **Cor Principal** |
| `primary-600` | `#2563EB` | **CTAs e Botões** |
| `primary-700` | `#1D4ED8` | **Hover States** |
| `primary-800` | `#1e40af` | Active states |
| `primary-900` | `#1e3a8a` | Deep accents |

### Gradientes

```css
/* Overlay de Hero Section */
background: linear-gradient(
  180deg,
  rgba(11, 15, 25, 0.5) 0%,
  rgba(11, 15, 25, 0.9) 50%,
  rgba(11, 15, 25, 1) 100%
);

/* Botões Primários */
background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);

/* Cards com Destaque */
background: linear-gradient(
  135deg,
  rgba(59, 130, 246, 0.1) 0%,
  rgba(37, 99, 235, 0.05) 100%
);
```

---

## 📝 Tipografia

### Font Stack

```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### Hierarquia de Tamanhos

| Elemento | Tamanho | Peso | Uso |
|----------|---------|------|-----|
| Hero H1 | `3rem` (48px) | 800 | Títulos principais de landing pages |
| H1 | `2.25rem` (36px) | 700 | Títulos de seção |
| H2 | `1.875rem` (30px) | 600 | Subtítulos |
| H3 | `1.5rem` (24px) | 600 | Cards e boxes |
| Body Large | `1.125rem` (18px) | 400 | Texto de destaque |
| Body | `1rem` (16px) | 400 | Texto padrão |
| Small | `0.875rem` (14px) | 400 | Legendas e metadados |

---

## 🧩 Componentes

### Botões

#### Botão Primário (CTA)
```tsx
<button className="
  px-8 py-4
  bg-[#2563EB]
  hover:bg-[#1D4ED8]
  text-white font-semibold
  rounded-lg
  shadow-[0_0_30px_rgba(37,99,235,0.6)]
  hover:shadow-[0_0_40px_rgba(37,99,235,0.8)]
  transition-all duration-300
">
  Quero Implantar
</button>
```

#### Botão Secundário
```tsx
<button className="
  px-8 py-4
  border-2 border-[#3B82F6]
  text-[#3B82F6] font-semibold
  rounded-lg
  hover:bg-[#3B82F6]/10
  transition-all duration-300
">
  Saiba Mais
</button>
```

### Cards

#### Card Padrão
```tsx
<div className="
  bg-[#1a1f2e]
  border border-[#2d3748]
  rounded-xl
  p-6
  hover:bg-[#242937]
  hover:border-[#3B82F6]
  transition-all duration-300
">
  {/* Conteúdo */}
</div>
```

#### Card com Gradiente
```tsx
<div className="
  bg-gradient-to-br
  from-[#1a1f2e] to-[#0B0F19]
  border border-[#3B82F6]/30
  rounded-xl
  p-6
  shadow-lg
">
  {/* Conteúdo */}
</div>
```

### Hero Section

```tsx
<section className="
  relative w-full
  min-h-screen
  bg-[#0B0F19]
  flex items-center justify-center
  overflow-hidden
">
  {/* Gradiente Overlay */}
  <div className="absolute inset-0 bg-gradient-to-b from-[#0B0F19]/50 via-[#0B0F19]/90 to-[#0B0F19]" />

  {/* Conteúdo */}
  <div className="relative z-10 max-w-6xl mx-auto px-4 text-center">
    <h1 className="text-5xl md:text-6xl font-extrabold text-white mb-6">
      Implantamos sua{' '}
      <span className="text-[#3B82F6]">Máquina de Vendas</span>
      {' '}em até 90 Dias
    </h1>
    {/* Resto do conteúdo */}
  </div>
</section>
```

---

## 🎭 Variações

### Dashboards

```css
Background: #0B0F19
Sidebar: #1a1f2e
Cards: #242937
Accent: #3B82F6
```

### Landing Pages

```css
Background: #0B0F19
Hero Gradient: linear-gradient(180deg, #0B0F19 0%, #1a1f2e 100%)
Cards: rgba(26, 31, 46, 0.6) com backdrop-blur
Accent: #3B82F6
```

### Modo Light (Futuro)

```css
Background: #FFFFFF
Cards: #F9FAFB
Text: #111827
Accent: #2563EB
```

---

## 🚀 Como Usar

### 1. Instalação

Copie os seguintes arquivos para seu projeto:

```bash
/lib/mottivme-theme.ts       # Configuração do tema
/app/globals.css             # Variáveis CSS
tailwind.config.ts           # Config do Tailwind
```

### 2. Import do Tema

```tsx
import { mottivmeTheme } from '@/lib/mottivme-theme'

// Usar cores
const primaryColor = mottivmeTheme.colors.primary[500]

// Usar gradientes
const heroGradient = mottivmeTheme.gradients.hero
```

### 3. Classes Tailwind

```tsx
// Background Mottivme
className="bg-[#0B0F19]"
className="bg-mottivme-dark"

// Texto com cor da marca
className="text-[#3B82F6]"
className="text-primary-500"

// Botão CTA
className="bg-[#2563EB] hover:bg-[#1D4ED8]"
className="bg-primary-600 hover:bg-primary-700"
```

### 4. CSS Variables

```css
/* No seu CSS */
.hero-section {
  background: var(--mottivme-dark);
  color: var(--mottivme-text-primary);
}

.cta-button {
  background: var(--mottivme-blue-dark);
}

.cta-button:hover {
  background: var(--mottivme-blue-darker);
}
```

---

## 📦 Exemplos de Uso

### Landing Page Hero

```tsx
export default function Hero() {
  return (
    <section className="relative min-h-screen bg-[#0B0F19]">
      <div className="absolute inset-0 bg-gradient-to-b from-[#0B0F19]/50 to-[#0B0F19]" />

      <div className="relative z-10 container mx-auto px-4 pt-32 text-center">
        <h1 className="text-5xl font-extrabold text-white mb-8">
          Implantamos sua{' '}
          <span className="text-[#3B82F6]">Máquina de Vendas</span>
          {' '}em até 90 Dias
        </h1>

        <p className="text-xl text-[#D1D5DB] mb-12 max-w-3xl mx-auto">
          Com rotina validada, CRM plug & play, Social Selling que gera caixa,
          e scripts testados. Com ou sem agentes de IA operando pra você.
        </p>

        <div className="flex gap-4 justify-center">
          <button className="
            px-8 py-4
            bg-[#2563EB] hover:bg-[#1D4ED8]
            text-white font-semibold
            rounded-lg
            shadow-[0_0_30px_rgba(37,99,235,0.6)]
            transition-all
          ">
            Quero Implantar Minha Máquina de Vendas →
          </button>
        </div>

        <div className="mt-16 flex gap-8 justify-center text-[#D1D5DB]">
          <div className="flex items-center gap-2">
            ✓ Sem depender de anúncios
          </div>
          <div className="flex items-center gap-2">
            ✓ Sem criar conteúdo todo dia
          </div>
          <div className="flex items-center gap-2">
            ✓ Sem contratar equipe sênior
          </div>
        </div>
      </div>
    </section>
  )
}
```

### Dashboard Card

```tsx
export default function MetricCard({ title, value, change }: Props) {
  return (
    <div className="
      bg-[#1a1f2e]
      border border-[#2d3748]
      rounded-xl
      p-6
      hover:bg-[#242937]
      hover:border-[#3B82F6]
      transition-all
    ">
      <h3 className="text-[#9CA3AF] text-sm font-medium mb-2">
        {title}
      </h3>
      <p className="text-white text-3xl font-bold mb-1">
        {value}
      </p>
      <p className="text-[#3B82F6] text-sm">
        {change > 0 ? '↑' : '↓'} {Math.abs(change)}%
      </p>
    </div>
  )
}
```

---

## 🔄 Atualizações

**Versão:** 1.0.0
**Última atualização:** Dezembro 2024
**Mantido por:** Mottivme Team

### Changelog

- **v1.0.0** - Sistema de design inicial com cores, tipografia e componentes base

---

## 📞 Suporte

Para dúvidas ou sugestões sobre o design system, entre em contato com a equipe de desenvolvimento Mottivme.

**Cores da Marca:** Sempre use `#3B82F6` (azul) e `#0B0F19` (dark) como base.
