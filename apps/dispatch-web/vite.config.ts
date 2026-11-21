import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    testTimeout: 15000,
    env: {
      VITE_API_URL: 'http://localhost:3000/api/v1',
      VITE_WS_URL: 'http://localhost:3000',
      VITE_GOOGLE_MAPS_KEY: '',
      VITE_GOOGLE_MAPS_MAP_ID: '',
    },
  },
})
