# Markdown Quick Look Plugin

This project implements a macOS Quick Look Preview Extension for Markdown files, using a web-based rendering engine similar to Markdown Preview Enhanced.

## Directory Structure

*   `web-renderer/`: A Node.js project that bundles the Markdown rendering logic (Markdown-it, Mermaid, Katex, CSS).
*   `PreviewViewController.swift`: The Swift code for the Quick Look Extension.

## Setup Instructions

### 1. Build the Web Renderer

First, we need to generate the `bundle.js` and `index.html` that the macOS extension will load.

```bash
cd web-renderer
npm install
npm run build
```

This will create a `dist/` directory containing:
*   `index.html`
*   `bundle.js`

### 2. Create Xcode Project

1.  Open **Xcode**.
2.  Create a new project: **macOS** -> **App**.
    *   Product Name: `MarkdownQuickLook`
    *   Interface: `Storyboard` or `SwiftUI` (doesn't matter much for the container app).
    *   Language: `Swift`.
3.  Add a **Quick Look Preview Extension** target:
    *   File -> New -> Target...
    *   macOS -> **Quick Look Preview Extension**.
    *   Product Name: `MarkdownPreview`.
    *   Language: `Swift`.

### 3. Integrate Files

1.  **Add Web Assets**:
    *   Drag the `web-renderer/dist` folder into your Xcode project (ensure it's added to the **MarkdownPreview** extension target).
    *   **Important**: Select "Create folder references" (blue folder icon) so the structure is preserved.
2.  **Add Swift Code**:
    *   Open `PreviewViewController.swift` in Xcode (in the `MarkdownPreview` group).
    *   Replace its content with the content of `PreviewViewController.swift` provided in this directory.

### 4. Configure Info.plist

1.  Open `Info.plist` for the **MarkdownPreview** extension.
2.  Ensure `NSExtension` -> `NSExtensionAttributes` -> `QLSupportedContentTypes` contains markdown UTIs:
    *   `net.daringfireball.markdown`
    *   `public.plain-text` (optional, but risky as it might override default text viewer)
3.  (Optional) If you want to support Mermaid diagrams smoothly, ensure the App Sandbox allows outgoing network if you switch to CDN (currently we use local bundle so no network needed).

### 5. Build and Run

1.  Select the **MarkdownPreview** scheme.
2.  Build and Run.
3.  To test, select a Markdown file in Finder and press Space. You may need to run `qlmanage -r` in terminal to reset Quick Look cache.

## Features

*   **Markdown**: CommonMark + GFM (Tables, Task Lists).
*   **Math**: KaTeX support (`$E=mc^2$`).
*   **Diagrams**: Mermaid support (```mermaid ... ```).
*   **Highlighting**: Syntax highlighting for code blocks.
*   **Theme**: GitHub Light/Dark mode (auto-detect).
