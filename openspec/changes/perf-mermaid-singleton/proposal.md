# Change: Mermaid 实例单例化，消除重复 initialize 开销

## Why

当前 `renderMarkdown()` 每次被调用时都执行 `mermaid.initialize()`（`src/index.ts` 第 300 行），该调用会完全重建 mermaid 内部状态，耗时约 200 ms。在同一文件的热渲染场景（如文件监控触发重渲染、主题切换）中，这个开销完全无必要，因为 mermaid 主题只有 `default` 和 `dark` 两种，切换频率极低。

基线数据：`05-mermaid.md` 热启动 p50 = 184 ms（Layer 1）/ 233 ms（Layer 2），其中约 200 ms 来自 `initialize()`。

## What Changes

- 在模块作用域引入 `mermaidInstance` 和 `mermaidCurrentTheme` 两个缓存变量
- 首次渲染时初始化 mermaid 实例，后续复用
- 仅当主题发生变化时才重新调用 `mermaid.initialize()`
- mermaid 动态 import 保持不变（仍在首次遇到 mermaid 块时懒加载）

## Impact

- Affected specs: `js-renderer`
- Affected code: `web-renderer/src/index.ts`（第 296–393 行，mermaid 渲染块）
- 预期收益: Mermaid 热启动 p50 从 ~184 ms 降至 ~10–20 ms（-90%）
- 主题切换场景：首次切换后新主题触发一次 re-initialize，后续同主题渲染无额外开销
