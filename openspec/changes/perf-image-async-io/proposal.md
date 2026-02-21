# Change: collectImageData() 移至后台线程，解除主线程阻塞

## Why

`PreviewViewController.renderPendingMarkdown()` 在主线程同步调用 `collectImageData()`（第 959 行），该函数内部执行：正则匹配提取图片路径 + 同步文件 I/O（`Data(contentsOf:)`）+ base64 编码。对于包含多张本地图片的文档，这会在主线程上阻塞数十至数百毫秒，导致 QuickLook 窗口出现卡顿感。

## What Changes

- 将 `renderPendingMarkdown()` 重构为 async，使用 `Task.detached(priority: .userInitiated)` 在后台收集图片数据
- 图片数据收集完成后，回到 `MainActor` 执行 JS 调用
- `collectImageData()` 本身逻辑不变，仅执行线程改变

## Impact

- Affected specs: `swift-preview`
- Affected code: `Sources/MarkdownPreview/PreviewViewController.swift`（`renderPendingMarkdown()` 函数）
- 预期收益: 含本地图片文档的主线程阻塞消除；用户感知延迟降低
- 无功能性变更：最终调用 JS 的行为完全相同
