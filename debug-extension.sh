#!/bin/bash

# 终端调试脚本 - Terminal Debugging Script

echo "🐛 Starting Quick Look Extension Debug Session..."
echo ""

# Find the app path
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/MarkdownQuickLook-*/Build/Products/Debug -name "MarkdownQuickLook.app" 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ App not found. Run 'make app' first."
    exit 1
fi

echo "✅ Found app: $APP_PATH"
echo ""

# Launch the app
echo "📱 Launching app..."
open "$APP_PATH"
sleep 2

# Reset Quick Look
echo "🔄 Resetting Quick Look..."
qlmanage -r
qlmanage -r cache
sleep 1

echo ""
echo "📡 Starting log stream... (Press Ctrl+C to stop)"
echo "    Watching for: QuickLook, MarkdownPreview, WebKit errors"
echo ""

# Start log streaming in background and save to file
LOG_FILE="/tmp/quicklook-debug-$(date +%s).log"
log stream --predicate '(subsystem CONTAINS "QuickLook") OR (subsystem CONTAINS "WebKit") OR (process == "qlmanage") OR (process == "quicklookd") OR (eventMessage CONTAINS "MarkdownPreview") OR (eventMessage CONTAINS "index.html")' --level debug --color none > "$LOG_FILE" &
LOG_PID=$!

echo "💾 Logs saving to: $LOG_FILE"
echo ""
echo "Now perform these steps:"
echo "  1. In Finder, select test-sample.md"
echo "  2. Press SPACE to trigger Quick Look"
echo "  3. Wait 5 seconds"
echo ""
echo "Press ENTER when done to view captured logs..."
read

# Kill log stream
kill $LOG_PID 2>/dev/null

echo ""
echo "📋 Captured logs:"
echo "=================================================="
cat "$LOG_FILE"
echo "=================================================="
echo ""
echo "Full log saved to: $LOG_FILE"
