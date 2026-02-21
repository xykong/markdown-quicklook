## 前置条件

- `perf-bundle-split` 变更已完成并部署（`loadFileURL` 模式已生效）

## 1. 注册 LocalSchemeHandler（Swift）

- [x] 1.1 在 `Sources/MarkdownPreview/PreviewViewController.swift` 的 `viewDidLoad` 中，在 `WKWebViewConfiguration` 初始化之后、创建 `InteractiveWebView` 之前，添加：
  ```swift
  let schemeHandler = LocalSchemeHandler()
  webConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme: "local-md")
  ```
- [x] 1.2 将 `schemeHandler` 存为实例变量（`var localSchemeHandler: LocalSchemeHandler?`），以便在 `preparePreviewOfFile` 时设置 `baseDirectory`

## 2. 传递文件路径而非 imageData（Swift）

- [x] 2.1 在 `preparePreviewOfFile()` 中，将 `schemeHandler.baseDirectory` 设置为 `url.deletingLastPathComponent()`（markdown 文件所在目录）
- [x] 2.2 从 options 字典中移除 `options["imageData"] = self.collectImageData(...)` 这一行
- [x] 2.3 确认 `options["baseUrl"]` 仍然传递（`file://` 格式的 markdown 文件目录）

## 3. 移除 collectImageData 方法（Swift）

- [x] 3.1 删除 `PreviewViewController.swift` 中的 `collectImageData(from:content:)` 方法（约第 830–916 行）
- [x] 3.2 确认无其他调用点（使用 `grep` 检查）

## 4. 修改 JS 图片渲染逻辑（TypeScript）

- [x] 4.1 在 `web-renderer/src/index.ts` 的 markdown-it 图片 token 规则中，将本地文件路径转换为 `local-md:///absolute/path` 格式（基于传入的 `baseUrl` 拼接相对路径）
- [x] 4.2 移除 `index.ts` 中 base64 → Blob URL 转换代码块（约第 235–276 行）
- [x] 4.3 移除 `renderMarkdown` 函数签名中 `imageData` 参数及相关类型定义
- [x] 4.4 运行 `npm test` 确认现有 Jest 测试仍通过

## 5. 验证构建与渲染

- [x] 5.1 运行 `make generate && make app`，确认 Swift 编译无错误
- [x] 5.2 运行 `./install.sh` 安装，测试含本地图片的 markdown 文件（`06-images.md`）图片正常渲染
- [x] 5.3 测试不含图片的 markdown 文件（`01-tiny.md`）渲染不受影响
- [x] 5.4 测试含网络图片 URL 的 markdown（scheme handler 不处理 `http://`，应降级为原始 URL）

## 6. 性能验证

- [x] 6.1 运行 Layer 2 benchmark（XCTest）：对比有图片文件的 warm/cold render 时间
- [x] 6.2 将结果存入 `benchmark/results/swift-bench-after-scheme-handler.json`
