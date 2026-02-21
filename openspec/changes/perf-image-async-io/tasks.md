## 1. 重构 renderPendingMarkdown() 为异步

- [ ] 1.1 在 `Sources/MarkdownPreview/PreviewViewController.swift` 中，将 `renderPendingMarkdown()` 内对 `collectImageData()` 的同步调用提取到 `Task.detached(priority: .userInitiated)` 块中
- [ ] 1.2 在 Task 内收集 imageData 后，使用 `await MainActor.run { ... }` 回到主线程，再执行 `evaluateJavaScript` 调用
- [ ] 1.3 确保 `collectImageData()` 函数本身不标记 `@MainActor`（它只做纯 I/O，不需要主线程）
- [ ] 1.4 确保弱引用 `[weak self]` 正确捕获，避免在 Task 执行期间 ViewController 被释放导致崩溃

## 2. 验证

- [ ] 2.1 运行 `make build_renderer && make app`，确认 Swift 编译无错误
- [ ] 2.2 手动测试：打开包含本地图片的 Markdown 文件，确认图片正常显示
- [ ] 2.3 手动测试：快速在多个 Markdown 文件间切换（QuickLook 列表导航），确认不崩溃、不显示错误图片
- [ ] 2.4 检查 Console.app 日志，确认无 `Main actor-isolated` 相关运行时警告

## 3. 更新测试

- [ ] 3.1 运行 `xcodebuild test -project FluxMarkdown.xcodeproj -scheme Markdown -destination 'platform=macOS,arch=arm64'`，确认所有 XCTest 通过
