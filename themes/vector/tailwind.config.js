/** @type {import('tailwindcss').Config} */
module.exports = {
   content: [
     /* css from assets folder */
     "assets/css/*.css",
     /* relevant files from the blog + theme */
     "../../content/**/*.{html,md}",
     "../../layouts/**/*.html",
     /* relevant files from the theme */
     "./layouts/**/*.html",
     /* also pick nested css from theme */
     "../../assets/css/*.css",
   ],
   screens:{
      sm:'480px',
      md:'768px',
      lg:'976px',
      xl:'1440px'
   },
   theme: {
    extend: {
       backgroundImage: {
         'hero': "url('/hero.webp')",
         'hero-2': "url('/idea-2.jpg')",
      },
      colors: {
        /* Moonlet Color Scheme */
        dust: {
          100: '#f0f0f0',
          300: '#cdcfd5',
          400: '#787a80',
          500: '#42495f',
          800: '#22242a',
          900: '#191a1f',
        },
        moon: {
          DEFAULT: '#00daff',
          900: '#172d35',
        },
        mars: '#fd8565',
        earth: '#3a4eff',
        sun: '#ffffa2',

        /* Nord Theme Colors (existing) */
        nord: {
          polar: {
            night: '#2E3440',
            light: '#ECEFF4',
          },
          snow: {
            storm: '#9CA3B0',
            white: '#E5E9F0',
          },
          frost: {
            arctic: '#88C0D0',
            pale: '#81A1C1',
            deep: '#5E81AC',
          },
          aurora: {
            purple: '#B48EAD',
            blue: '#5E81AC',
            cyan: '#88C0D0',
            teal: '#8FBCBB',
            green: '#A3BE8C',
            orange: '#D08770',
            red: '#BF616A',
            yellow: '#EBCB8B',
          },
        },
      },
      fontFamily: {
        sans: ['Inter Tight', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      transitionProperty: {
        'colors': 'background-color, border-color, color, fill, stroke',
      },
     },
   },
   plugins: [
      require('@tailwindcss/typography'),
   ],
}
