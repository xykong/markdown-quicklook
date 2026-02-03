#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APPCAST_FILE="$PROJECT_ROOT/appcast.xml"
DMG_FILE="$1"
PRIVATE_KEY="$PROJECT_ROOT/.sparkle-keys/sparkle_private_key.pem"

if [ -z "$DMG_FILE" ]; then
    echo "❌ Error: DMG file not specified"
    echo "Usage: $0 <path-to-dmg>"
    exit 1
fi

if [ ! -f "$DMG_FILE" ]; then
    echo "❌ Error: DMG file not found: $DMG_FILE"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "❌ Error: Private key not found: $PRIVATE_KEY"
    echo "   Run './scripts/generate-sparkle-keys.sh' first"
    exit 1
fi

VERSION_FILE="$PROJECT_ROOT/.version"
if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ Error: Version file not found: $VERSION_FILE"
    exit 1
fi

BASE_VERSION=$(cat "$VERSION_FILE")
COMMIT_COUNT=$(git -C "$PROJECT_ROOT" rev-list --count HEAD 2>/dev/null || echo "0")
FULL_VERSION="$BASE_VERSION.$COMMIT_COUNT"

FILE_SIZE=$(stat -f%z "$DMG_FILE" 2>/dev/null || stat -c%s "$DMG_FILE" 2>/dev/null)
PUB_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")

echo "📝 Generating Sparkle signature..."
SIGNATURE=$(openssl dgst -sha256 -sign "$PRIVATE_KEY" "$DMG_FILE" | openssl base64 -A)

if [ -z "$SIGNATURE" ]; then
    echo "❌ Failed to generate signature"
    exit 1
fi

echo ""
echo "📦 Release Info:"
echo "   Version: $FULL_VERSION"
echo "   Build:   $COMMIT_COUNT"
echo "   Size:    $FILE_SIZE bytes"
echo "   Date:    $PUB_DATE"
echo ""

DOWNLOAD_URL="https://github.com/xykong/markdown-quicklook/releases/download/v$FULL_VERSION/MarkdownPreviewEnhanced.dmg"
RELEASE_URL="https://github.com/xykong/markdown-quicklook/releases/tag/v$FULL_VERSION"

CHANGELOG_ENTRY=$(git -C "$PROJECT_ROOT" log -1 --pretty=format:"%B" 2>/dev/null || echo "Update to version $FULL_VERSION")

TEMP_ITEM=$(cat <<EOF
        <item>
            <title>Version $FULL_VERSION</title>
            <link>$RELEASE_URL</link>
            <sparkle:version>$COMMIT_COUNT</sparkle:version>
            <sparkle:shortVersionString>$FULL_VERSION</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>11.0</sparkle:minimumSystemVersion>
            <pubDate>$PUB_DATE</pubDate>
            <enclosure 
                url="$DOWNLOAD_URL"
                sparkle:edSignature="$SIGNATURE"
                length="$FILE_SIZE"
                type="application/octet-stream" />
            <description><![CDATA[
                <h2>更新内容</h2>
                <pre>$CHANGELOG_ENTRY</pre>
                
                <p><a href="$RELEASE_URL">查看完整更新日志</a></p>
            ]]></description>
        </item>
        
EOF
)

if [ ! -f "$APPCAST_FILE" ]; then
    echo "❌ Error: Appcast file not found: $APPCAST_FILE"
    exit 1
fi

perl -i -pe "s|<!--.*?TEMPLATE.*?-->|$TEMP_ITEM\n\$&|s" "$APPCAST_FILE"

echo "✅ Appcast updated successfully!"
echo ""
echo "📄 File: $APPCAST_FILE"
echo ""
echo "🔍 Signature: ${SIGNATURE:0:50}..."
echo ""
echo "Next steps:"
echo "  1. Review the appcast.xml file"
echo "  2. Commit and push to GitHub"
echo "  3. Deploy to GitHub Pages"
echo ""
