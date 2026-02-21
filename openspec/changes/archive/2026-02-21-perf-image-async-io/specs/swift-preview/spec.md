## ADDED Requirements

### Requirement: 本地图片数据异步收集

`PreviewViewController` SHALL 在非主线程收集本地图片的 base64 数据，不阻塞主线程。

#### Scenario: 含图片文档后台收集数据

- **WHEN** `renderPendingMarkdown()` 被调用，且当前文件包含本地图片引用
- **THEN** 系统 SHALL 在后台并发队列（`userInitiated` 优先级）执行 `collectImageData()`，主线程不阻塞

#### Scenario: 数据收集完成后切回主线程执行 JS

- **WHEN** 后台线程完成 `collectImageData()` 的执行
- **THEN** 系统 SHALL 回到主线程（`MainActor`），将图片数据连同 Markdown 内容一起传给 `evaluateJavaScript(renderMarkdown)`

#### Scenario: ViewController 释放时安全取消

- **WHEN** `collectImageData()` 在后台执行期间，对应的 `PreviewViewController` 被 QuickLook 释放（用户关闭预览）
- **THEN** 系统 SHALL 安全地丢弃后台任务结果，不发生崩溃或访问已释放对象
