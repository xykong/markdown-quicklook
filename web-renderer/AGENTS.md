# AGENTS.md - web-renderer

## OVERVIEW
TypeScript/Vite-based Markdown renderer for macOS QuickLook.
Transforms Markdown into HTML with math, diagrams, and syntax highlighting.

## STRUCTURE
- `src/`: TypeScript source code.
- `test/`: Jest test suites for rendering logic.
- `dist/`: Compiled assets (bundle.js, main.css, index.html).
- `node_modules/`: Project dependencies.
- `index.html`: Base HTML structure and entry point.
- `vite.config.ts`: Vite build configuration.

## WHERE TO LOOK
- `src/index.ts`: Main entry. Exposes `window.renderMarkdown`.
- `index.html`: Base HTML structure for WebView.
- `vite.config.ts`: Build config; handles output naming and asset paths.
- `package.json`: Dependency list and build scripts.

## CONVENTIONS
- **Renderer**: `markdown-it` with KaTeX, Mermaid, and Highlight.js.
- **Testing**: Jest tests required for all rendering logic.
- **Inter-op**: JS-to-Swift via `window.webkit.messageHandlers.logger`.
- **Styling**: GitHub-style CSS; fonts/assets inlined/referenced via Vite.
- **Build**: Output to `dist/` is directly referenced by Xcode project.

## COMMANDS
- `npm install`: Install dev/prod dependencies.
- `npm run build`: Production build (Vite).
- `npm run dev`: Start Vite development server.
- `npm test`: Execute Jest test suites.
