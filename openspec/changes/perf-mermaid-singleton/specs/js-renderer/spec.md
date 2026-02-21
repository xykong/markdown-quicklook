## ADDED Requirements

### Requirement: Mermaid 实例单例缓存

渲染引擎 SHALL 在模块作用域维护 mermaid 实例的单例缓存，避免每次 `renderMarkdown()` 调用时重复执行 `mermaid.initialize()`。

#### Scenario: 首次渲染初始化 mermaid

- **WHEN** `renderMarkdown()` 首次遇到 mermaid 代码块，且模块作用域中尚无 mermaid 实例缓存
- **THEN** 系统 SHALL 动态 import mermaid 模块，调用 `mermaid.initialize()` 并缓存实例和当前主题

#### Scenario: 同主题连续渲染跳过 initialize

- **WHEN** `renderMarkdown()` 再次遇到 mermaid 代码块，且当前主题与上次初始化时相同
- **THEN** 系统 SHALL 直接使用缓存的 mermaid 实例渲染，不调用 `mermaid.initialize()`

#### Scenario: 主题切换触发 re-initialize

- **WHEN** `renderMarkdown()` 收到与上次不同的主题参数（如从 `default` 变为 `dark`）
- **THEN** 系统 SHALL 以新主题调用一次 `mermaid.initialize()`，更新缓存主题，然后渲染图表

#### Scenario: 热启动 Mermaid 渲染性能达标

- **WHEN** 对 `05-mermaid.md`（含 8 个 Mermaid 图表）执行 Layer 1 benchmark 热启动测试
- **THEN** `renderMarkdown()` 热启动 p50 SHALL 不超过 30 ms（基线 184 ms）
