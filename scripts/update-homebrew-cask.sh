#!/bin/bash
set -e

VERSION=$1
DMG_PATH="build/artifacts/MarkdownPreviewEnhanced.dmg"
CASK_FILE="../homebrew-tap/Casks/markdown-preview-enhanced.rb"

if [ -z "$VERSION" ]; then
    echo "❌ Error: Version not provided"
    echo "Usage: $0 <VERSION>"
    echo "Example: $0 1.3.73"
    exit 1
fi

if [ ! -f "$DMG_PATH" ]; then
    echo "❌ Error: DMG not found at $DMG_PATH"
    echo "Please build the DMG first with: make dmg"
    exit 1
fi

if [ ! -f "$CASK_FILE" ]; then
    echo "❌ Error: Homebrew Cask file not found at $CASK_FILE"
    echo "Please ensure homebrew-tap repository is cloned at ../homebrew-tap"
    exit 1
fi

echo "🍺 Updating Homebrew Cask for v$VERSION..."
echo ""

SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "✅ Calculated SHA256: $SHA256"
echo ""

CURRENT_VERSION=$(grep "version '" "$CASK_FILE" | head -1 | sed "s/.*version '\(.*\)'/\1/")
CURRENT_SHA256=$(grep "sha256 '" "$CASK_FILE" | head -1 | sed "s/.*sha256 '\(.*\)'/\1/")

echo "📊 Current Cask Info:"
echo "   Version: $CURRENT_VERSION"
echo "   SHA256:  $CURRENT_SHA256"
echo ""
echo "📊 New Cask Info:"
echo "   Version: $VERSION"
echo "   SHA256:  $SHA256"
echo ""

if [ "$CURRENT_VERSION" = "$VERSION" ] && [ "$CURRENT_SHA256" = "$SHA256" ]; then
    echo "✅ Homebrew Cask is already up to date!"
    exit 0
fi

echo "🔧 Updating Cask file..."

sed -i '' "s/version '.*'/version '$VERSION'/" "$CASK_FILE"
sed -i '' "s/sha256 '.*'/sha256 '$SHA256'/" "$CASK_FILE"

echo "✅ Cask file updated successfully"
echo ""

cd "$(dirname "$CASK_FILE")/.."

if ! git diff --quiet Casks/markdown-preview-enhanced.rb; then
    echo "📝 Changes detected:"
    git diff Casks/markdown-preview-enhanced.rb
    echo ""
    
    read -p "👉 Commit and push changes? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add Casks/markdown-preview-enhanced.rb
        git commit -m "chore(cask): update markdown-preview-enhanced to v$VERSION"
        git push origin master
        echo "✅ Changes committed and pushed to homebrew-tap"
    else
        echo "⚠️  Changes not committed. Please commit manually:"
        echo "   cd $(pwd)"
        echo "   git add Casks/markdown-preview-enhanced.rb"
        echo "   git commit -m 'chore(cask): update markdown-preview-enhanced to v$VERSION'"
        echo "   git push origin master"
    fi
else
    echo "ℹ️  No changes detected in Cask file"
fi

echo ""
echo "🎉 Done! Users can now install v$VERSION with:"
echo "   brew update"
echo "   brew upgrade markdown-preview-enhanced"
