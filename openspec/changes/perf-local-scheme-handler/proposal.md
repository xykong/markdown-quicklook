# Change: 启用 LocalSchemeHandler，替代 base64 图片数据传递

## Why

当前图片加载路径冗余且低效：Swift 在主线程同步读取所有图片文件并 base64 编码（`collectImageData()`），将编码后的字符串通过 JS 调用传入 WebView，JS 再用 `atob()` 解码 + `Uint8Array` 构造 `Blob` 对象 + `URL.createObjectURL()` 生成 Blob URL，最终才能显示图片。这条链路每次 `renderMarkdown()` 都完整执行，包含大量不必要的 CPU 和内存开销。

`LocalSchemeHandler.swift` 已完整实现并通过了 `WKURLSchemeHandler` 协议（scheme: `local-md://`），但从未注册到任何 `WKWebViewConfiguration`。启用它可让 WebKit 直接按需加载图片文件，彻底消除 base64 往返。

**注意**：本变更依赖 `perf-bundle-split`（P0）已完成——多文件 bundle 结合 `loadFileURL` 模式与 scheme handler 兼容性更好；single-file 内联模式下 `data:` URL 已绕过了此问题。

## What Changes

- 在 `PreviewViewController.viewDidLoad()` 的 `WKWebViewConfiguration` 初始化中注册 `LocalSchemeHandler`，scheme 为 `local-md`
- 设置 `LocalSchemeHandler.baseDirectory` 为预览文件所在目录（安全范围书签或直接路径）
- `preparePreviewOfFile()` 中停止调用 `collectImageData()`，改为将文件基础路径（`file://` URL）传给 JS options
- JS `renderMarkdown()` 接收 `baseUrl` 而非 `imageData`，markdown-it 图片插件将相对路径转换为 `local-md:///absolute/path/to/image.png` URL
- 移除 `index.ts` 中 base64 → Blob URL 转换逻辑（约 40 行）
- 移除 `collectImageData()` 方法（约 90 行 Swift 代码）

## Impact

- Affected specs: `swift-preview`、`js-renderer`
- Affected code:
  - `Sources/MarkdownPreview/PreviewViewController.swift`（注册 handler、移除 `collectImageData`、修改 options 构造）
  - `Sources/MarkdownPreview/LocalSchemeHandler.swift`（无需修改，已实现完整）
  - `web-renderer/src/index.ts`（移除 base64→blob 转换；图片 token 规则改用 `local-md://` URL）
- 依赖: `perf-bundle-split` 须先完成（`loadFileURL` 模式）
- 预期收益:
  - 消除每次预览时的主线程同步 I/O（`collectImageData` 读取所有图片文件）
  - 图片按需加载（WebKit 只请求视口内可见图片）
  - JS 端消除 `atob` + `Uint8Array` + `Blob` 创建开销
- 风险: scheme handler 在 QuickLook Extension 沙箱中的安全范围资源访问需验证；`NSFileCoordinator` 的异步性需确保 `WKURLSchemeTask` 生命周期正确
