import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  base: './', // Use relative paths for assets
  build: {
    outDir: 'dist',
    assetsDir: '', // Put assets directly in dist or define structure
    sourcemap: false,
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.html'),
      },
      output: {
        // Force fixed filenames to match old Webpack output
        entryFileNames: 'bundle.js',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name && assetInfo.name.endsWith('.css')) {
            return 'main.css';
          }
          return '[name][extname]';
        },
      },
    },
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
