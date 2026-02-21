## Context

Vite 构建两种模式对比：

| 维度 | singlefile（当前）| 多文件（目标）|
|---|---|---|
| `dist/` 输出 | 单个 5.5 MB index.html | index.html (~10 KB) + assets/*.js + assets/*.css |
| WebKit 加载方式 | `loadHTMLString()` - Swift 读取整个字符串再传入 | `loadFileURL()` - WebKit 直接读取文件 |
| mermaid 加载 | 全量打包进 HTML（即使无 mermaid 块也加载） | 动态 import 时才从磁盘加载 mermaid chunk |
| 首次解析耗时 | ~120 ms | ~10–20 ms（index.html 仅几 KB）|

## Goals / Non-Goals

- Goals: 减少 WebKit 冷启动解析耗时；实现 mermaid 真正懒加载
- Non-Goals: 不引入 CDN 或网络加载（沙箱限制，必须离线可用）

## Decisions

- Decision: 使用 `loadFileURL(_:allowingReadAccessTo:)` 替代 `loadHTMLString()`
  - 原因: WebKit 通过文件 URL 加载时可利用内部缓存，且不需要 Swift 读取整个文件内容到内存
  - 替代方案: 保留 `loadHTMLString` 但传入小 HTML + 通过 `WKURLSchemeHandler` 服务资源 → 复杂度过高，方案一更简单

- Decision: mermaid 单独分包而非完全剥离
  - 原因: Vite `manualChunks` 确保 mermaid 被独立打包为一个 chunk，动态 import 时才加载
  - 替代方案: 完全移除 mermaid、改为外部 CDN → 不可行（沙箱无网络）

## Risks / Trade-offs

- `loadFileURL` 的 `allowingReadAccessTo` 参数必须授权整个 `dist/` 目录，确保 `assets/` 下的 JS/CSS chunk 可被加载
- 沙箱模型: QuickLook Extension 的 `MarkdownPreview.entitlements` 已有 `user-selected.read-only`，但 bundle 内部文件读取不需要此权限，`loadFileURL` 对 bundle 资源是允许的
- `crossorigin` 属性: 当前 build script 通过 `sed` 移除 `crossorigin`；多文件模式下需验证是否仍需此处理

## Migration Plan

1. 修改 `vite.config.ts`，移除 `viteSingleFile()`，添加 `manualChunks`
2. 运行 `npm run build`，验证 `dist/` 多文件输出
3. 修改 `PreviewViewController.viewDidLoad()`，改用 `loadFileURL`
4. 修改 `MarkdownWebView.swift`，同步更新主 App 路径
5. 运行 `make generate && make app`，验证构建
6. 测试所有 7 个 fixture 文件的渲染结果
7. 运行 Layer 3 benchmark，对比冷启动数据

## Open Questions

- `loadFileURL` 在 QuickLook Extension 沙箱中读取 App Bundle 内 `dist/` 目录是否需要额外 entitlement？（预期不需要，bundle 资源读取不受沙箱限制）
