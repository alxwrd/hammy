import colors from 'tailwindcss/colors'

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    colors: {
      accent: colors.emerald,
      white: colors.white,
      gray: colors.gray,
    },
  },
  plugins: [],
}
