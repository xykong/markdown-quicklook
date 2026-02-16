#!/bin/bash
# Local Sparkle Update Testing Script
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "════════════════════════════════════════════════════════════════"
echo "  🧪 Sparkle 本地更新测试"
echo "════════════════════════════════════════════════════════════════"
echo ""

# 1. 临时移除修复，构建旧版本 (1.6.93)
echo "📦 步骤 1/5: 构建旧版本 (v1.6.93 - 无修复)..."
git stash push -m "test-update: stash fixes" Sources/Markdown/Markdown.entitlements Sources/Markdown/Info.plist
git checkout HEAD~1 -- Sources/Markdown/Markdown.entitlements Sources/Markdown/Info.plist 2>/dev/null || true

# 手动设置版本号为 93
OLD_VERSION="1.6.93"
sed -i.bak 's/^1\.[0-9]*/1.6/' .version
make app CONFIGURATION=Release

# 保存旧版本 app
OLD_APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FluxMarkdown.app" -path "*/Build/Products/Release/*" | head -n 1)
if [ -z "$OLD_APP_PATH" ]; then
    echo "❌ 找不到构建的应用"
    git stash pop || true
    exit 1
fi

TMP_DIR=$(mktemp -d)
cp -R "$OLD_APP_PATH" "$TMP_DIR/FluxMarkdown v93.app"
echo "   ✓ 旧版本已保存到: $TMP_DIR"

# 2. 恢复修复，构建新版本 (1.6.95)
echo ""
echo "📦 步骤 2/5: 构建新版本 (v1.6.95 - 包含修复)..."
git stash pop || true
mv .version.bak .version 2>/dev/null || true

# 增加版本号到 95
echo "1.6" > .version
git commit --allow-empty -m "test: bump to v95" --no-verify 2>/dev/null || true
make app CONFIGURATION=Release

# 创建 DMG
make dmg

# 3. 创建本地 appcast.xml
echo ""
echo "📝 步骤 3/5: 创建本地 appcast.xml..."

DMG_PATH="$PROJECT_ROOT/build/artifacts/FluxMarkdown.dmg"
DMG_SIZE=$(stat -f%z "$DMG_PATH")
NEW_VERSION=$(defaults read "$OLD_APP_PATH/Contents/Info.plist" CFBundleShortVersionString)

# 使用真实的 EdDSA 签名（从现有 appcast.xml 复制）
REAL_SIGNATURE=$(grep 'sparkle:edSignature=' appcast.xml | head -1 | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')

cat > "$TMP_DIR/appcast.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>FluxMarkdown (本地测试)</title>
        <item>
            <title>Version $NEW_VERSION</title>
            <sparkle:version>95</sparkle:version>
            <sparkle:shortVersionString>$NEW_VERSION</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>11.0</sparkle:minimumSystemVersion>
            <pubDate>$(date -u +"%a, %d %b %Y %H:%M:%S %z")</pubDate>
            <enclosure 
                url="file://$DMG_PATH"
                sparkle:edSignature="$REAL_SIGNATURE"
                length="$DMG_SIZE"
                type="application/octet-stream" />
            <description><![CDATA[
                <h2>测试版本</h2>
                <ul>
                    <li>修复 Sparkle 安装器错误</li>
                    <li>添加必要的沙盒权限例外</li>
                </ul>
            ]]></description>
        </item>
    </channel>
</rss>
EOF

echo "   ✓ 本地 appcast.xml 已创建"

# 4. 修改旧版本的 Info.plist 指向本地 appcast
echo ""
echo "🔧 步骤 4/5: 配置旧版本使用本地 appcast..."
/usr/libexec/PlistBuddy -c "Set :SUFeedURL file://$TMP_DIR/appcast.xml" "$TMP_DIR/FluxMarkdown v93.app/Contents/Info.plist"
echo "   ✓ SUFeedURL 已设置为本地路径"

# 5. 安装旧版本
echo ""
echo "📲 步骤 5/5: 安装旧版本 (v1.6.93)..."
rm -rf "/Applications/FluxMarkdown.app"
cp -R "$TMP_DIR/FluxMarkdown v93.app" "/Applications/FluxMarkdown.app"
xattr -cr "/Applications/FluxMarkdown.app"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ 测试环境准备完成"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 测试信息:"
echo "   • 已安装版本: v1.6.93 (无修复)"
echo "   • 可更新版本: v1.6.95 (包含修复)"
echo "   • DMG 路径: $DMG_PATH"
echo "   • Appcast: $TMP_DIR/appcast.xml"
echo ""
echo "🧪 开始测试:"
echo "   1. 打开 'FluxMarkdown' 应用"
echo "   2. 点击 '检查更新...' 或按 ⌘U"
echo "   3. 应该检测到 v1.6.95"
echo "   4. 点击 'Install' 按钮"
echo "   5. 观察是否成功安装（之前会报错）"
echo ""
echo "🗑️  测试完成后清理:"
echo "   rm -rf '$TMP_DIR'"
echo ""
