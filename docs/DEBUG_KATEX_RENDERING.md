# Debug: KaTeX Rendering Issue

## Issue Description
Formulas in `test-sample.md` are rendering incorrectly. Characters are overlapping and positioning is off, as seen in the provided screenshot.

## Initial Observations
- The screenshot shows both inline (`$E=mc^2$`) and block math rendering issues.
- The quadratic formula block is severely garbled, suggesting missing CSS or font issues.
- The logs show "Markdown Renderer Fully Loaded" and "Render complete", so the JS execution seems to be finishing.

## Reproduction Steps
1. Open `test-sample.md` with `qlmanage -p test-sample.md`.
2. Observe the rendered output.

## Investigation Log
### 1. File Analysis
- `test-sample.md`: Valid Markdown with standard KaTeX syntax blocks.
- `web-renderer/package.json`: Includes `katex` and `markdown-it-katex`.
- `web-renderer/src/index.ts`: Imports `'katex/dist/katex.min.css'`.

### 2. Webpack Configuration Analysis
- `web-renderer/webpack.config.js`:
    - Handles `.ts`/`.tsx` with `ts-loader`.
    - Handles `.css` with `style-loader` and `css-loader`.
    - **CRITICAL MISSING**: No rule to handle font files (`.woff`, `.woff2`, `.ttf`, etc.).

### 3. Root Cause
KaTeX CSS references font files for its math symbols. Webpack is likely ignoring them or not bundling them correctly because there is no loader configured for font file extensions. This results in the browser failing to load the specific KaTeX fonts, causing the rendering artifacts seen in the screenshot.

## Resolution Plan
1. Update `web-renderer/webpack.config.js` to include a rule for font assets.
2. Rebuild the renderer (`npm run build`).
3. Verify that font files are emitted to the `dist` directory.

## Resolution Status
- **Fix Applied**: Updated `webpack.config.js` to include an asset resource rule for fonts.
- **Verification**: Ran `npm run build`. The output confirmed that font files (e.g., `fonts/KaTeX_AMS-Regular.woff2`, etc.) are now emitted to the `dist/fonts` directory.
- **Conclusion**: The issue was caused by missing font assets in the final bundle. Configuring webpack to process these files resolves the rendering issues.