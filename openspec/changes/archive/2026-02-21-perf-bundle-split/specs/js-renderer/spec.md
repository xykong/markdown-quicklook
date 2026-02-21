## MODIFIED Requirements

### Requirement: Vite Build Output Format
The renderer build system SHALL produce a multi-file output: a small `index.html` entry point (≤ 20 KB) plus separate JS/CSS chunks in `assets/`, with mermaid isolated in its own chunk named `mermaid-[hash].js`.

#### Scenario: Standard build output
- **WHEN** `npm run build` is executed
- **THEN** `dist/index.html` is ≤ 20 KB
- **AND** `dist/assets/` contains at least one JS chunk and one CSS file
- **AND** a mermaid-specific JS chunk exists under `dist/assets/mermaid-*.js`

#### Scenario: No vite-plugin-singlefile dependency
- **WHEN** the build configuration is inspected
- **THEN** `vite-plugin-singlefile` is not listed in `package.json` dependencies
- **AND** `viteSingleFile()` is not present in `vite.config.ts`

## ADDED Requirements

### Requirement: Mermaid Lazy Chunk Loading
The renderer SHALL load the mermaid library only when a mermaid diagram block is present in the rendered content, using dynamic `import()` against the pre-built mermaid chunk.

#### Scenario: Document with no mermaid blocks
- **WHEN** `renderMarkdown()` is called with content that contains no mermaid code blocks
- **THEN** the mermaid JS chunk is NOT fetched or executed
- **AND** render completes without loading the mermaid chunk

#### Scenario: Document with mermaid blocks
- **WHEN** `renderMarkdown()` is called with content containing at least one mermaid fenced code block
- **THEN** the mermaid chunk is dynamically imported before diagram rendering
- **AND** all diagrams are rendered correctly
