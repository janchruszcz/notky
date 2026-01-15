const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,rb}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        handwriting: ['Caveat', 'cursive'],
      },
      colors: {
        // Cork board colors
        cork: {
          50: '#fdf8f3',
          100: '#f5e6d3',
          200: '#e8ceb0',
          300: '#d4a574',
          400: '#c4854a',
          500: '#a66b2f',
          600: '#8b5a2b',
          700: '#6b4423',
          800: '#4a2f18',
          900: '#2d1c0f',
        },
        // Sticky note colors - realistic pastel
        note: {
          yellow: '#fff9c4',
          pink: '#f8bbd9',
          blue: '#b3e5fc',
          green: '#c8e6c9',
          purple: '#e1bee7',
          orange: '#ffe0b2',
          white: '#fafafa',
        },
      },
      boxShadow: {
        'note': '2px 4px 8px rgba(0, 0, 0, 0.15), 0 1px 3px rgba(0, 0, 0, 0.1)',
        'note-hover': '4px 8px 16px rgba(0, 0, 0, 0.2), 0 2px 6px rgba(0, 0, 0, 0.1)',
        'note-drag': '8px 16px 32px rgba(0, 0, 0, 0.25)',
        'pin': '0 2px 4px rgba(0, 0, 0, 0.3), inset 0 1px 2px rgba(255, 255, 255, 0.3)',
      },
      animation: {
        'fade-in': 'fadeIn 0.2s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'scale-in': 'scaleIn 0.15s ease-out',
        'wiggle': 'wiggle 0.3s ease-in-out',
        'pin-drop': 'pinDrop 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        scaleIn: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        wiggle: {
          '0%, 100%': { transform: 'rotate(-1deg)' },
          '50%': { transform: 'rotate(1deg)' },
        },
        pinDrop: {
          '0%': { transform: 'translateY(-20px) scale(0.8)', opacity: '0' },
          '100%': { transform: 'translateY(0) scale(1)', opacity: '1' },
        },
      },
      backgroundImage: {
        'cork-pattern': "url(\"data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E\")",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
