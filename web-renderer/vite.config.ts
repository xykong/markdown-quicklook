import { defineConfig } from 'vite';
import path from 'path';
import { viteSingleFile } from 'vite-plugin-singlefile';

export default defineConfig({
  plugins: [viteSingleFile()],
  base: './', // Use relative paths for assets
  build: {
    outDir: 'dist',
    assetsDir: '', // Put assets directly in dist or define structure
    sourcemap: false,
    emptyOutDir: true,
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
