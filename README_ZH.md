# Markdown Preview Enhanced for macOS QuickLook 扩展

[English README](README.md)

macOS QuickLook 扩展，用于精美预览 Markdown 文件，支持完整渲染、语法高亮、数学公式和图表。

**本项目受 [markdown-preview-enhanced](https://github.com/shd101wyy/markdown-preview-enhanced) 启发，并使用了其部分内容。**

## 功能特性

- **Markdown**: 支持 CommonMark + GFM (表格, 任务列表, 删除线)
- **数学公式**: 支持 KaTeX 数学表达式 (`$E=mc^2$`)
- **图表**: 支持 Mermaid 流程图、时序图等
- **语法高亮**: 支持代码块语法高亮
- **Emoji**: 支持 `:emoji_name:` 语法
- **目录导航**: 自动生成可折叠的文档目录，智能高亮当前章节
- **主题**: 跟随系统自动切换亮色/暗色模式

## 快速开始

### 安装

#### 方法 1: Homebrew (推荐)

```bash
brew tap xykong/tap
brew install --cask markdown-preview-enhanced
```

#### 方法 2: 手动安装 (DMG)

1. 从 [Releases](https://github.com/xykong/markdown-quicklook/releases) 页面下载最新的 `.dmg` 文件。
2. 打开 `.dmg` 文件。
3. 将 **Markdown Preview Enhanced.app** 拖入 **Applications** (应用程序) 文件夹。

#### 方法 3: 源码构建 (开发者)

```bash
# 克隆仓库
git clone https://github.com/xykong/markdown-quicklook.git
cd markdown-quicklook

# 构建并安装
make install
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

### 🛑 常见问题："应用已损坏" 或 "无法验证开发者"

由于本项目是开源软件，未购买 Apple 开发者证书进行公证，首次运行时 macOS Gatekeeper 可能会提示 **“Markdown Preview Enhanced.app 已损坏，无法打开”** 或 **“无法验证开发者”**。

**方法 1: 命令行修复 (推荐)**

在终端 (Terminal) 中运行以下命令以移除隔离属性：

```bash
xattr -cr "/Applications/Markdown Preview Enhanced.app"
```

**方法 2: 手动授权**

1. 打开 **系统设置 (System Settings)** > **隐私与安全性 (Privacy & Security)**。
2. 向下滚动到 **安全性 (Security)** 部分。
3. 你应该会看到提示 "Markdown Preview Enhanced.app 已被阻止使用..."。
4. 点击 **仍要打开 (Open Anyway)**。
5. 输入密码确认。

运行后即可正常打开应用。

### 测试

完成上述激活步骤后，测试扩展：

```bash
qlmanage -p test-sample.md
```

或者直接在 Finder 中选中任意 `.md` 文件并按空格键 (QuickLook快捷键)。

## 致谢

本项目在很大程度上受到 Yiyi Wang (shd101wyy) 创建的 [markdown-preview-enhanced](https://github.com/shd101wyy/markdown-preview-enhanced) 的启发，并使用了其中的部分内容。我们衷心感谢作者的杰出工作。

本项目遵守 `markdown-preview-enhanced` 所使用的 University of Illinois/NCSA Open Source License 协议。

## 许可协议

**非商业许可协议**

本软件仅供个人、教育和非商业用途免费使用。未经作者事先书面许可，严禁用于商业用途。详情请参阅 [LICENSE](LICENSE) 文件。

本项目同时遵守所使用的第三方库的许可协议，包括：
- `markdown-preview-enhanced` (NCSA License)
- `markdown-it` (MIT License)
- `highlight.js` (BSD-3-Clause License)
- `katex` (MIT License)
- `mermaid` (MIT License)