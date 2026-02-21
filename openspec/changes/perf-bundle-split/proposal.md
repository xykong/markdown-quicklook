# Change: 拆分 5.5 MB 单文件 Bundle，改用 loadFileURL 加载

## Why

当前 `vite-plugin-singlefile` 将所有 JS、CSS、字体内联为单个 5.5 MB HTML 文件。WebKit 每次冷启动都需要完整解析这个巨型文件，占冷启动总耗时约 55%（~120 ms）。这是当前所有可优化项中收益最大的一个。

基线数据：Layer 3 `01-tiny.md`（最小文件，无实质渲染）冷启动 p50 = 205 ms，其中约 120 ms 用于 HTML 解析。

## What Changes

- **BREAKING**: 移除 `vite-plugin-singlefile`，改为标准多文件 Vite 输出
- 将 mermaid 单独分包（`manualChunks: { mermaid: ['mermaid'] }`），支持真正的按需懒加载
- `PreviewViewController.viewDidLoad()` 从 `loadHTMLString()` 改为 `loadFileURL(_:allowingReadAccessTo:)`
- `MarkdownWebView.swift`（主 App 路径）同步更新
- `project.yml` 确保 `web-renderer/dist/` 目录以 folder reference 完整打包（非单文件内联）

## Impact

- Affected specs: `js-renderer`、`swift-preview`
- Affected code:
  - `web-renderer/vite.config.ts`（移除 singlefile 插件，添加 manualChunks）
  - `web-renderer/package.json`（移除 `vite-plugin-singlefile` 依赖）
  - `Sources/MarkdownPreview/PreviewViewController.swift`（`viewDidLoad` 加载方式）
  - `Sources/Markdown/MarkdownWebView.swift`（主 App 路径）
  - `project.yml`（dist 目录 type 保持 folder）
- 预期收益: Layer 3 冷启动 p50 从 ~205 ms 降至 ~80–100 ms（-50%~60%）
- 风险: 沙箱权限需验证；`crossorigin` 属性处理需更新
