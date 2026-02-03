# 自动更新系统使用指南

本项目实现了混合更新策略，同时支持 Homebrew 用户和 DMG 手动安装用户。

## 架构概览

```
┌─────────────────────────────────────────────────────────┐
│                    启动时检测                            │
│                                                         │
│    Homebrew 安装?                    DMG 安装?          │
│         │                               │              │
│         ▼                               ▼              │
│  GitHub API 检查              Sparkle 自动更新          │
│  提示用户运行 brew upgrade    后台检查 → 自动下载安装    │
└─────────────────────────────────────────────────────────┘
```

## 功能特性

### 对于 Homebrew 用户

- **智能检测**: 自动识别通过 `brew install --cask` 安装的应用
- **温和提醒**: 发现新版本时，弹出提示建议运行 `brew upgrade`
- **命令复制**: 一键复制更新命令到剪贴板
- **定期检查**: 每周自动检查一次新版本

### 对于 DMG 用户

- **Sparkle 自动更新**: 使用业界标准的 Sparkle 2.8.1 框架
- **后台检查**: 每天自动检查更新（可配置）
- **安全验证**: EdDSA 签名验证，确保更新来源可信
- **无感安装**: 下载完成后一键安装，自动重启应用

## 开发者指南

### 首次配置

#### 1. 生成 Sparkle 密钥对

```bash
./scripts/generate-sparkle-keys.sh
```

这将生成：
- `.sparkle-keys/sparkle_public_key.txt` - 公钥（安全分享）
- `.sparkle-keys/sparkle_private_key.pem` - 私钥（绝对保密！）

#### 2. 更新 Info.plist

将生成的公钥填入 `Sources/Markdown/Info.plist`：

```xml
<key>SUPublicEDKey</key>
<string>YOUR_GENERATED_PUBLIC_KEY_HERE</string>
```

替换 `SPARKLE_PUBLIC_KEY_PLACEHOLDER`。

#### 3. 重新生成 Xcode 项目

```bash
make generate
```

这会：
- 拉取 Sparkle 2.8.1 依赖
- 重新生成 `.xcodeproj` 文件
- 配置正确的链接设置

#### 4. 测试构建

```bash
make build
```

确保没有编译错误。

### 发布新版本

#### 完整发布流程

```bash
# 1. 发布 patch 版本（默认）
make release

# 或发布 minor 版本
make release minor

# 或发布 major 版本
make release major
```

这个命令会自动：
1. ✅ 更新 `.version` 文件
2. ✅ 更新 `CHANGELOG.md`
3. ✅ 创建 git tag
4. ✅ 构建 DMG
5. ✅ 创建 GitHub Release
6. ✅ 生成 Sparkle 签名
7. ✅ 更新 `appcast.xml`
8. ✅ 更新 Homebrew Cask

#### 手动步骤（如需要）

**1. 仅生成 appcast**

```bash
./scripts/generate-appcast.sh build/artifacts/MarkdownPreviewEnhanced.dmg
```

**2. 仅更新 Homebrew Cask**

```bash
./scripts/update-homebrew-cask.sh 1.4.85
```

### 部署 appcast.xml

Sparkle 需要访问 `appcast.xml` 来检查更新。推荐使用 GitHub Pages：

#### 方法 1: GitHub Pages（推荐）

1. 在 GitHub 仓库设置中启用 Pages
2. 选择 `main` 分支的 `/docs` 目录（或根目录）
3. 将 `appcast.xml` 提交到对应目录
4. 访问 `https://YOUR_USERNAME.github.io/YOUR_REPO/appcast.xml`

#### 方法 2: GitHub Releases（备选）

在 `Info.plist` 中使用：

```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/xykong/markdown-quicklook/master/appcast.xml</string>
```

### 安全最佳实践

#### 私钥管理

⚠️ **绝对不要提交私钥到 Git！**

```bash
# .gitignore 中已包含
.sparkle-keys/
```

**推荐存储方式：**
- 1Password / LastPass 等密码管理器
- 加密的 USB 驱动器
- 云端加密存储（如 1Password Vault）

**CI/CD 环境：**
- 使用 GitHub Secrets 存储私钥
- 在 workflow 中临时解密使用
- 构建完成后立即删除

#### 签名验证

每次发布时，Sparkle 会：
1. 使用私钥对 DMG 文件生成 EdDSA 签名
2. 签名存储在 `appcast.xml` 中
3. 用户端使用公钥验证签名
4. 签名不匹配 → 拒绝安装

## 用户体验

### DMG 用户更新流程

1. **后台检查**: 应用每天检查一次更新（启动后 + 定时）
2. **发现新版本**: 弹出通知对话框
   ```
   ┌─────────────────────────────────────┐
   │  发现新版本 1.4.85                   │
   │                                     │
   │  新增功能：                          │
   │  - 混合更新策略支持                  │
   │  - Sparkle 自动更新                 │
   │                                     │
   │  [稍后提醒]  [安装更新]               │
   └─────────────────────────────────────┘
   ```
3. **下载更新**: 显示下载进度条
4. **安装更新**: 自动安装，提示重启应用

### Homebrew 用户更新流程

1. **检测到新版本**: 弹出提示对话框
   ```
   ┌─────────────────────────────────────┐
   │  发现新版本 1.4.85                   │
   │                                     │
   │  您通过 Homebrew 安装了此应用。      │
   │  请在终端运行以下命令更新：          │
   │                                     │
   │  brew upgrade markdown-preview-     │
   │  enhanced                           │
   │                                     │
   │  [知道了]  [复制命令]                 │
   └─────────────────────────────────────┘
   ```
2. **复制命令**: 点击"复制命令"后，命令自动复制到剪贴板
3. **手动更新**: 在终端粘贴并执行命令

## 配置选项

### Info.plist 配置

```xml
<!-- 更新源 URL -->
<key>SUFeedURL</key>
<string>https://xykong.github.io/markdown-quicklook/appcast.xml</string>

<!-- 公钥 -->
<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY</string>

<!-- 启用自动检查 -->
<key>SUEnableAutomaticChecks</key>
<true/>

<!-- 检查间隔（秒）：86400 = 24小时 -->
<key>SUScheduledCheckInterval</key>
<integer>86400</integer>

<!-- 允许自动安装（无需用户确认）-->
<key>SUAllowsAutomaticUpdates</key>
<true/>
```

### 自定义检查频率

修改 `MarkdownApp.swift` 中的常量：

```swift
// Homebrew 用户检查间隔（秒）
let oneWeekInSeconds: TimeInterval = 604800  // 7天

// 首次启动后延迟检查（秒）
let initialCheckDelay: TimeInterval = 10  // 10秒
```

## 故障排查

### Sparkle 未启动

**症状**: 应用启动但没有更新检查

**检查：**
1. Info.plist 中的公钥是否正确
2. appcast.xml 是否可访问
3. Console.app 中查看错误日志

```bash
log stream --predicate 'process == "Markdown Preview Enhanced"' --level debug
```

### 签名验证失败

**症状**: 提示"更新签名无效"

**原因：**
- 公钥与私钥不匹配
- appcast.xml 中的签名错误
- DMG 文件在签名后被修改

**解决：**
```bash
# 重新生成签名
./scripts/generate-appcast.sh build/artifacts/MarkdownPreviewEnhanced.dmg
```

### Homebrew 检测错误

**症状**: Homebrew 用户看到 Sparkle 更新对话框

**检查：**
```swift
// MarkdownApp.swift
let isHomebrewInstall = appPath.contains("/opt/homebrew/Caskroom/") ||
                        appPath.contains("/usr/local/Caskroom/")
```

确保检测逻辑覆盖所有 Homebrew 安装路径。

## 参考资源

- [Sparkle 官方文档](https://sparkle-project.org/documentation/)
- [Sparkle 沙盒支持](https://sparkle-project.org/documentation/sandboxing/)
- [EdDSA 签名指南](https://sparkle-project.org/documentation/package-updates/)
- [Homebrew Cask 文档](https://docs.brew.sh/Cask-Cookbook)

## 版本历史

- **1.4.82+**: 混合更新策略（Sparkle + Homebrew 检测）
- **1.4.0-1.4.81**: 仅手动更新（GitHub Releases + Homebrew）
