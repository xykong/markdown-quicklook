# Troubleshooting Guide

## Extension Not Registered

### Issue
运行 `qlmanage -m | grep -i markdown` 或 `pluginkit -m -A -D -p com.apple.quicklook.preview | grep markdownquicklook` 没有找到扩展。

### Root Cause 1：未通过 Xcode 正确运行 Host App
Quick Look 扩展的注册机制要求：
1. 扩展必须通过 **Xcode Run** 运行，而不是简单的 `open` 命令
2. macOS 会缓存扩展列表，需要特殊的刷新流程

### Root Cause 2：扩展没有开启沙箱（Sandbox）
如果在日志中看到类似：

```bash
Ignoring mis-configured plugin ... plug-ins must be sandboxed
```

说明扩展本身没有启用 App Sandbox，`pkd` 会直接拒绝注册该插件，即使它已经被打包进 `.app` 中。

修复方式（已经在当前项目中完成）：

1. 为 Host App 和 Extension 分别添加 Entitlements 文件：
   - `Sources/MarkdownQuickLook/MarkdownQuickLook.entitlements`
   - `Sources/MarkdownPreview/MarkdownPreview.entitlements`

2. 在两个 target 的设置中都启用沙箱，并允许用户选择的文件只读访问：

   ```xml
   <!-- 必须：开启 App Sandbox -->
   <key>com.apple.security.app-sandbox</key>
   <true/>

   <!-- 推荐：允许读取用户在 Finder 中选择的 markdown 文件 -->
   <key>com.apple.security.files.user-selected.read-only</key>
   <true/>

   <!-- 仅限开发环境：允许调试器附加 -->
   <key>com.apple.security.get-task-allow</key>
   <true/>
   ```

3. 在 `project.yml` 中为两个 target 指定 `CODE_SIGN_ENTITLEMENTS`（当前仓库已配置好）：

   ```yaml
   MarkdownQuickLook:
     settings:
       CODE_SIGN_ENTITLEMENTS: Sources/MarkdownQuickLook/MarkdownQuickLook.entitlements

   MarkdownPreview:
     settings:
       CODE_SIGN_ENTITLEMENTS: Sources/MarkdownPreview/MarkdownPreview.entitlements
   ```

4. 重新生成并构建工程：

   ```bash
   make app
   ```

5. 再次查看插件是否被注册：

   ```bash
   pluginkit -m -A -D -p com.apple.quicklook.preview | grep -i markdownquicklook
   ```

   正常情况下应能看到：

   ```bash
   com.markdownquicklook.app.MarkdownPreview(1.0)
   ```

### Solution: Use Xcode Debugger

#### 方法 1: 通过 Xcode 运行 (推荐)
```bash
# 1. 生成工程
make generate

# 2. 在 Xcode 中打开
open MarkdownQuickLook.xcodeproj

# 3. 在 Xcode 中:
#    - 选择 MarkdownQuickLook scheme
#    - 按 Cmd+R 运行
#    - 保持 App 运行状态

# 4. 在新终端窗口:
qlmanage -r
qlmanage -r cache
killall Finder

# 5. 测试
#    在 Finder 中选中 test-sample.md，按空格
```

#### 方法 2: 使用 qlmanage 命令行测试
```bash
# 直接通过 qlmanage 调用扩展（绕过注册机制）
qlmanage -p test-sample.md
```

### Additional Checks

#### 查看系统日志
```bash
# Terminal 1: 启动日志监控
log stream --predicate 'subsystem contains "QuickLook" OR subsystem contains "MarkdownPreview"' --level debug

# Terminal 2: 打开文件触发 Quick Look
# 在 Finder 中按空格
```

#### 验证扩展文件完整性
```bash
APP_PATH=~/Library/Developer/Xcode/DerivedData/MarkdownQuickLook-*/Build/Products/Debug/MarkdownQuickLook.app

# 检查扩展是否存在
ls -la "$APP_PATH/Contents/PlugIns/MarkdownPreview.appex/Contents/MacOS"

# 检查 Web 资源是否正确复制
ls -la "$APP_PATH/Contents/PlugIns/MarkdownPreview.appex/Contents/Resources/dist"
```

## Known Limitations

### Debug vs Release Build
- **Debug 构建**: 使用的是开发签名，系统可能有额外限制
- **Workaround**: 在 Xcode 中通过 Product → Archive 创建 Release 版本

### Sandbox Restrictions  
macOS App Sandbox 会限制文件访问权限。如果 Markdown 文件引用了本地图片，可能需要额外的 Entitlements。
