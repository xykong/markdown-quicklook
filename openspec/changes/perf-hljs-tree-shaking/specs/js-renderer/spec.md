## ADDED Requirements

### Requirement: highlight.js 按需语言注册

渲染引擎 SHALL 使用 `highlight.js/core` 替代全量 `highlight.js` 导入，并仅注册以下预定义语言列表：javascript、typescript、python、bash、shell、sql、json、yaml、markdown、css、xml、html、go、rust、java、c、cpp、swift、kotlin、ruby、php、csharp、diff、dockerfile、nginx。

#### Scenario: 已注册语言正常高亮

- **WHEN** Markdown 代码块指定的语言在注册列表中（如 ` ```python `）
- **THEN** 代码块 SHALL 使用 highlight.js 正确渲染语法高亮

#### Scenario: 未注册语言静默降级

- **WHEN** Markdown 代码块指定的语言不在注册列表中（如 ` ```cobol `）
- **THEN** 代码块 SHALL 渲染为带语言 class 的无高亮代码块（`<code class="language-cobol">`），不抛出错误，不中断渲染

#### Scenario: bundle 体积减小

- **WHEN** 执行 `npm run build`
- **THEN** `dist/index.html` 中 highlight.js 相关代码体积 SHALL 不超过 100 KB（minified，相比基线 ~400 KB 减少 75% 以上）
