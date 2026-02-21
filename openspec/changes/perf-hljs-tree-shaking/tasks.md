## 1. 修改 highlight.js 引入方式

- [ ] 1.1 在 `web-renderer/src/index.ts` 中，将 `import hljs from 'highlight.js'` 替换为 `import hljs from 'highlight.js/core'`
- [ ] 1.2 在同文件中，按需 import 并注册以下语言：javascript、typescript、python、bash、shell、sql、json、yaml、markdown、css、xml、html、go、rust、java、c、cpp、swift、kotlin、ruby、php、csharp、diff、dockerfile、nginx
- [ ] 1.3 确认 `hljs.highlight()` 和 `hljs.getLanguage()` 调用逻辑不变

## 2. 验证

- [ ] 2.1 运行 `npm run build`，确认构建成功，无 TypeScript 错误
- [ ] 2.2 检查 `dist/index.html` 文件大小，确认 bundle 体积减小
- [ ] 2.3 手动测试：在测试文档中验证 JavaScript、Python、Bash、SQL、JSON 代码块高亮正常显示
- [ ] 2.4 手动测试：在测试文档中包含未注册语言（如 COBOL），确认降级为无高亮代码块（不崩溃）
- [ ] 2.5 运行 Layer 1 benchmark：`cd benchmark/js-bench && node bench.mjs`，与基线对比冷启动耗时

## 3. 更新测试

- [ ] 3.1 运行 `npm test`，确认现有 Jest 测试全部通过
