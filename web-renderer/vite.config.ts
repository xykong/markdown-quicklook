import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  plugins: [],
  base: './', // Use relative paths for assets
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    emptyOutDir: true,
    rollupOptions: {
      output: {
        manualChunks: {
          mermaid: ['mermaid']
        }
      }
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
  define: {
    // Polyfill process.env for dependencies that might expect it
    'process.env': {},
  },
});
