# Markdown Preview Enhanced macOS QuickLook 扩展

[English README](README.md)

macOS QuickLook 扩展，用于精美预览 Markdown 文件，支持完整渲染、语法高亮、数学公式和图表。

**本项目受 [markdown-preview-enhanced](https://github.com/shd101wyy/markdown-preview-enhanced) 启发，并使用了其部分内容。**

## 功能特性

- **Markdown**: 支持 CommonMark + GFM (表格, 任务列表, 删除线)
- **数学公式**: 支持 KaTeX 数学表达式 (`$E=mc^2$`)
- **图表**: 支持 Mermaid 流程图、时序图等
- **语法高亮**: 支持代码块语法高亮
- **Emoji**: 支持 `:emoji_name:` 语法
- **主题**: 跟随系统自动切换亮色/暗色模式

## 致谢

本项目在很大程度上受到 Yiyi Wang (shd101wyy) 创建的 [markdown-preview-enhanced](https://github.com/shd101wyy/markdown-preview-enhanced) 的启发，并使用了其中的部分内容。我们衷心感谢作者的杰出工作。

本项目遵守 `markdown-preview-enhanced` 所使用的 University of Illinois/NCSA Open Source License 协议。

## 快速开始

### 安装

运行安装脚本：

```bash
./install.sh
```

这将执行以下操作：
1. 构建包含所有依赖的应用程序
2. 将其安装到 `/Applications/Markdown Preview Enhanced.app`
3. 向系统注册应用
4. 重置 QuickLook 缓存

### ⚠️ 关键激活步骤

**必须完成此步骤，QuickLook 扩展才能正常工作：**

1. 在 Finder 中 **右键点击** (或 Control+点击) 任意 `.md` 文件
2. 选择 **"显示简介" (Get Info)** (或按 `⌘+I`)
3. 在 **"打开方式 (Open with:)"** 部分，选择 **Markdown Preview Enhanced.app**
4. 点击 **"全部更改... (Change All...)"** 按钮
5. 点击 **"继续"** 确认

这将把 Markdown Preview Enhanced 设置为所有 `.md` 文件的默认应用程序，这是 macOS 使用 QuickLook 扩展的**必要条件**。

### 测试

完成上述激活步骤后，测试扩展：

```bash
qlmanage -p test-sample.md
```

或者直接在 Finder 中选中任意 `.md` 文件并按空格键 (QuickLook快捷键)。

## 许可协议

**非商业许可协议**

本软件仅供个人、教育和非商业用途免费使用。未经作者事先书面许可，严禁用于商业用途。详情请参阅 [LICENSE](LICENSE) 文件。

本项目同时遵守所使用的第三方库的许可协议，包括：
- `markdown-preview-enhanced` (NCSA License)
- `markdown-it` (MIT License)
- `highlight.js` (BSD-3-Clause License)
- `katex` (MIT License)
- `mermaid` (MIT License)