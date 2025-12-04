/**
 * Mottivme Design System
 * Sistema de cores e estilos padronizados para todos os projetos Mottivme
 *
 * @version 1.0.0
 * @author Mottivme Team
 */

export const mottivmeTheme = {
  // ========================================
  // CORES PRIMÁRIAS
  // ========================================
  colors: {
    // Backgrounds
    background: {
      dark: '#0B0F19',        // Background principal dark
      darker: '#0a0e17',      // Background mais escuro
      card: '#1a1f2e',        // Cards e containers
      hover: '#242937',       // Hover states
    },

    // Azul Mottivme (Cor principal da marca)
    primary: {
      50: '#eff6ff',
      100: '#dbeafe',
      200: '#bfdbfe',
      300: '#93c5fd',
      400: '#60a5fa',
      500: '#3B82F6',        // Azul principal - títulos e destaques
      600: '#2563EB',        // Azul botões
      700: '#1D4ED8',        // Azul hover
      800: '#1e40af',
      900: '#1e3a8a',
    },

    // Textos
    text: {
      primary: '#FFFFFF',    // Texto principal
      secondary: '#D1D5DB',  // Texto secundário
      muted: '#9CA3AF',      // Texto desativado/menos importante
      link: '#3B82F6',       // Links
    },

    // Status/Feedback
    success: {
      bg: '#10b981',
      text: '#d1fae5',
    },
    warning: {
      bg: '#f59e0b',
      text: '#fef3c7',
    },
    error: {
      bg: '#ef4444',
      text: '#fee2e2',
    },
    info: {
      bg: '#3B82F6',
      text: '#dbeafe',
    },

    // Bordas
    border: {
      default: '#2d3748',
      light: '#374151',
      accent: '#3B82F6',
    },
  },

  // ========================================
  // GRADIENTES
  // ========================================
  gradients: {
    // Gradiente principal usado em backgrounds
    darkOverlay: 'linear-gradient(180deg, rgba(11, 15, 25, 0.5) 0%, rgba(11, 15, 25, 0.9) 50%, rgba(11, 15, 25, 1) 100%)',

    // Gradiente de botões
    primaryButton: 'linear-gradient(135deg, #3B82F6 0%, #2563EB 100%)',

    // Gradiente de cards
    card: 'linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(37, 99, 235, 0.05) 100%)',

    // Gradiente de hero section
    hero: 'linear-gradient(180deg, #0B0F19 0%, #1a1f2e 100%)',
  },

  // ========================================
  // SOMBRAS
  // ========================================
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    default: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',

    // Sombra azul para botões e destaques
    primaryGlow: '0 0 30px rgba(59, 130, 246, 0.6)',
    primaryGlowHover: '0 0 40px rgba(59, 130, 246, 0.8)',
  },

  // ========================================
  // TIPOGRAFIA
  // ========================================
  typography: {
    fontFamily: {
      sans: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      mono: "'Fira Code', 'Courier New', monospace",
    },
    fontSize: {
      xs: '0.75rem',      // 12px
      sm: '0.875rem',     // 14px
      base: '1rem',       // 16px
      lg: '1.125rem',     // 18px
      xl: '1.25rem',      // 20px
      '2xl': '1.5rem',    // 24px
      '3xl': '1.875rem',  // 30px
      '4xl': '2.25rem',   // 36px
      '5xl': '3rem',      // 48px
      '6xl': '3.75rem',   // 60px
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
      extrabold: '800',
    },
  },

  // ========================================
  // ESPAÇAMENTOS
  // ========================================
  spacing: {
    xs: '0.25rem',   // 4px
    sm: '0.5rem',    // 8px
    md: '1rem',      // 16px
    lg: '1.5rem',    // 24px
    xl: '2rem',      // 32px
    '2xl': '3rem',   // 48px
    '3xl': '4rem',   // 64px
  },

  // ========================================
  // BORDER RADIUS
  // ========================================
  borderRadius: {
    sm: '0.25rem',   // 4px
    md: '0.375rem',  // 6px
    lg: '0.5rem',    // 8px
    xl: '0.75rem',   // 12px
    '2xl': '1rem',   // 16px
    full: '9999px',  // Círculo completo
  },

  // ========================================
  // BREAKPOINTS (Responsividade)
  // ========================================
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
    '2xl': '1536px',
  },

  // ========================================
  // VARIAÇÕES DE TEMA
  // ========================================
  variants: {
    // Variação para dashboards
    dashboard: {
      background: '#0B0F19',
      sidebar: '#1a1f2e',
      card: '#242937',
      accent: '#3B82F6',
    },

    // Variação para landing pages
    landing: {
      background: '#0B0F19',
      hero: 'linear-gradient(180deg, #0B0F19 0%, #1a1f2e 100%)',
      card: 'rgba(26, 31, 46, 0.6)',
      accent: '#3B82F6',
    },

    // Variação para aplicações (futuro light mode)
    light: {
      background: '#FFFFFF',
      card: '#F9FAFB',
      text: '#111827',
      accent: '#2563EB',
    },
  },
} as const;

// ========================================
// HELPERS / UTILIDADES
// ========================================

/**
 * Retorna a classe CSS do Tailwind para uma cor do tema
 */
export const getColorClass = (color: keyof typeof mottivmeTheme.colors) => {
  return `text-[${mottivmeTheme.colors[color]}]`;
};

/**
 * Retorna a classe CSS do Tailwind para um background do tema
 */
export const getBgClass = (color: keyof typeof mottivmeTheme.colors) => {
  return `bg-[${mottivmeTheme.colors[color]}]`;
};

// ========================================
// EXPORT DEFAULT
// ========================================
export default mottivmeTheme;
