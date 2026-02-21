## 1. 修改 Vite 构建配置

- [x] 1.1 在 `web-renderer/vite.config.ts` 中移除 `viteSingleFile()` plugin 调用
- [x] 1.2 在 `web-renderer/vite.config.ts` 中移除 `assetsInlineLimit: 100000000`
- [x] 1.3 在 `web-renderer/vite.config.ts` 的 `build.rollupOptions.output` 中添加 `manualChunks: { mermaid: ['mermaid'] }`
- [x] 1.4 在 `web-renderer/package.json` 中移除 `vite-plugin-singlefile` 依赖
- [x] 1.5 运行 `npm run build`，确认 `dist/` 输出为多文件（`index.html` + `assets/` 目录）

## 2. 修改 Swift 加载方式（QuickLook Extension）

- [x] 2.1 在 `Sources/MarkdownPreview/PreviewViewController.swift` 的 `viewDidLoad` 中，将 `loadHTMLString()` 调用替换为 `webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())`
- [x] 2.2 移除原有的 `try String(contentsOf: url)` 字符串读取逻辑（不再需要把 HTML 读到内存）

## 3. 修改 Swift 加载方式（主 App）

- [x] 3.1 确认 `Sources/Markdown/MarkdownWebView.swift` 中已使用 `loadFileURL`（主 App 路径已正确，无需修改；若使用 `loadHTMLString` 则同步更新）

## 4. 验证构建与渲染

- [x] 4.1 运行 `make generate && make app`，确认 Swift 编译无错误
- [x] 4.2 运行 `./install.sh` 安装到本地，测试 7 个 benchmark fixture 文件均能正确渲染
- [x] 4.3 验证含图片的 markdown（`06-images.md`）图片渲染正常（`crossorigin` 处理）
- [x] 4.4 验证含 mermaid 图的 markdown（`04-mermaid.md`）懒加载 chunk 正常工作

## 5. 性能验证

- [x] 5.1 运行 Layer 3 benchmark：`cd benchmark && bash ql-bench/ql-bench.sh`
- [x] 5.2 与基线对比（目标：冷启动 p50 从 ~205 ms 降至 ≤ 120 ms）
- [x] 5.3 将结果存入 `benchmark/results/ql-bench-after-bundle-split.json`
