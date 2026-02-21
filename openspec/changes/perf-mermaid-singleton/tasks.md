## 1. 实现 Mermaid 单例缓存

- [ ] 1.1 在 `web-renderer/src/index.ts` 模块顶层（`let toc` 附近）添加两个缓存变量：
  ```typescript
  let mermaidInstance: typeof import('mermaid')['default'] | null = null;
  let mermaidCurrentTheme: string | null = null;
  ```
- [ ] 1.2 在 `renderMarkdown()` 的 mermaid 渲染块（当前第 296–393 行）中：
  - 将 `const mermaidModule = await import('mermaid'); const mermaid = mermaidModule.default;` 替换为：若 `mermaidInstance` 为 null 则 import 并赋值，否则直接使用缓存
  - 将无条件 `mermaid.initialize(...)` 替换为：仅当 `mermaidCurrentTheme !== mermaidTheme` 时才调用 `initialize()`，调用后更新 `mermaidCurrentTheme`

## 2. 验证

- [ ] 2.1 运行 `npm run build`，确认无 TypeScript 错误
- [ ] 2.2 手动测试：打开含 mermaid 图表的文件，确认图表正确渲染
- [ ] 2.3 手动测试：切换 Light ↔ Dark 主题，确认 mermaid 图表主题随之更新
- [ ] 2.4 手动测试：在同一文件触发多次重渲染（通过文件监控），确认图表持续正常显示
- [ ] 2.5 运行 Layer 1 benchmark：`cd benchmark/js-bench && node bench.mjs`，对比 `05-mermaid.md` 和 `07-mixed.md` 的热启动 p50（目标：从 ~184 ms 降至 ≤ 30 ms）

## 3. 更新测试

- [ ] 3.1 运行 `npm test`，确认现有 Jest 测试全部通过
