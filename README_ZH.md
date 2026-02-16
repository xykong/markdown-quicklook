# FluxMarkdown

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
- **缩放**: 支持键盘快捷键 (`Cmd +/-/0`)、滚轮缩放 (按住 `Cmd` 滚动) 和双指拉伸缩放，自动保存缩放级别
- **滚动位置记忆**: 自动记录每个 Markdown 文件的滚动位置，下次打开时自动恢复到上次查看的位置

## 快速开始

### 安装

#### 方法 1: Homebrew (推荐)

```bash
brew tap xykong/tap
brew install --cask flux-markdown
```

#### 方法 2: 手动安装 (DMG)

1. 从 [Releases](https://github.com/xykong/flux-markdown/releases) 页面下载最新的 `.dmg` 文件。
2. 打开 `.dmg` 文件。
3. 将 **FluxMarkdown.app** 拖入 **Applications** (应用程序) 文件夹。

#### 方法 3: 源码构建 (开发者)

```bash
# 克隆仓库
git clone https://github.com/xykong/flux-markdown.git
cd flux-markdown

# 构建并安装 (Release 版本)
make install

# 或安装 Debug 版本用于开发
make install debug
```

这将自动执行以下操作：
1. 构建包含所有依赖的应用程序
2. 将其安装到 `/Applications/FluxMarkdown.app`
3. 向系统注册应用
4. 启动应用完成注册
5. 设置为 `.md` 文件的默认处理程序
6. 重置 QuickLook 缓存

**安装现已完全自动化！** 安装后扩展将立即可用。

### 🛑 常见问题："应用已损坏" 或 "无法验证开发者"

由于本项目是开源软件，未购买 Apple 开发者证书进行公证，首次运行时 macOS Gatekeeper 可能会提示 **“FluxMarkdown.app 已损坏，无法打开”** 或 **“无法验证开发者”**。

**方法 1: 命令行修复 (推荐)**

在终端 (Terminal) 中运行以下命令以移除隔离属性：

```bash
xattr -cr "/Applications/FluxMarkdown.app"
```

**方法 2: 手动授权**

1. 打开 **系统设置 (System Settings)** > **隐私与安全性 (Privacy & Security)**。
2. 向下滚动到 **安全性 (Security)** 部分。
3. 你应该会看到提示 "FluxMarkdown.app 已被阻止使用..."。
4. 点击 **仍要打开 (Open Anyway)**。
5. 输入密码确认。

运行后即可正常打开应用。

### 🔐 首次使用权限请求

**当你首次预览包含图片的 Markdown 文件时**，macOS 会显示权限对话框：

```
"FluxMarkdown.app"想要
访问您主文件夹中的文件。

将应用数据分开存放可让您更轻松地
管理您的隐私和安全。

[不允许]  [允许]
```

**为什么需要此权限？**
- Markdown 文件经常使用相对路径引用图片（如 `../images/pic.png`）
- 这些图片可能位于当前目录之外
- macOS 沙盒环境默认仅允许访问当前文件，需要额外授权才能访问其他文件

**如何处理：**
1. ✅ 点击 **"允许"** - 推荐，获得完整功能
   - 所有类型的图片路径都能正常显示（相对路径、绝对路径）
   - 仅需授权一次
   
2. ❌ 点击 **"不允许"** - 功能受限
   - 同目录和子目录的图片仍可正常工作
   - 上层目录图片（`../`）和绝对路径可能无法显示

**安全说明：** 此权限仅授予访问**您的主文件夹**（`/Users/username/`），不包括系统文件或其他用户的数据。

### 测试

完成上述激活和权限步骤后，测试扩展：

```bash
qlmanage -p tests/fixtures/test-sample.md
```

或者直接在 Finder 中选中任意 `.md` 文件并按空格键 (QuickLook快捷键)。

## 🛠️ 常见问题排查

### 权限对话框反复弹出

**问题：** 每次预览 Markdown 文件时都会弹出权限对话框。

**解决方案：**
1. 确保点击的是 **"允许"**（而不是"不允许"）
2. 如果不小心点了"不允许"，需要重置权限：
   - 打开 **系统设置** > **隐私与安全性** > **文件和文件夹**
   - 找到 "FluxMarkdown"
   - 启用对主文件夹的访问权限
3. 或者完全重置权限：
   ```bash
   tccutil reset All com.xykong.Markdown
   ```
   然后重新预览 Markdown 文件，这次点击"允许"。

### 图片无法显示

**问题：** Markdown 文件中的部分或全部图片无法显示。

**检查清单：**

1. **检查文件权限** - 确保在权限对话框中点击了"允许"

2. **验证图片路径：**
   - ✅ 同目录：`![](./image.png)` → 应该可以
   - ✅ 子目录：`![](./images/pic.png)` → 应该可以
   - ✅ 上层目录：`![](../images/pic.png)` → 需要"允许"权限
   - ✅ 绝对路径（主文件夹内）：`![](/Users/username/Pictures/pic.png)` → 需要"允许"权限
   - ❌ 系统路径：`![](/System/...)` → 不支持
   - ❌ 其他用户：`![](/Users/other-user/...)` → 不支持

3. **检查图片文件是否存在：**
   ```bash
   # 在终端中检查文件是否存在
   ls -la /path/to/your/image.png
   ```

4. **支持的图片格式：**
   - ✅ PNG, JPEG, GIF, WebP, SVG
   - ✅ 网络图片 (HTTPS)
   - ⚠️ HTTP 图片（可能被安全策略阻止）

### QuickLook 预览无法触发

**问题：** 在 `.md` 文件上按空格键没有反应。

**解决方案：**
1. 重置 QuickLook 缓存：
   ```bash
   qlmanage -r
   qlmanage -r cache
   ```

2. 手动设置默认处理程序：
   - 右键点击 `.md` 文件 → **显示简介**
   - 在"打开方式"下拉框中选择 **FluxMarkdown**
   - 点击 **全部更改...**

3. 注销并重新登录（或重启 Mac）

### 手动管理权限

**查看当前权限：**
- **系统设置** > **隐私与安全性** > **文件和文件夹**
- 找到 "FluxMarkdown"

**撤销权限：**
- 关闭权限开关
- 下次预览文件时会重新询问

**预先授权（不弹对话框）：**
- 可以在使用应用前，在系统设置中预先授权

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
