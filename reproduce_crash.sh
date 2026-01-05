#!/bin/bash

# Kill any running instances
pkill -f "Markdown Preview Enhanced"

# Define log file
LOG_FILE="/tmp/markdown_crash_debug.log"
rm -f "$LOG_FILE"

echo "Starting Log Stream..."
# Capture relevant subsystems
log stream --predicate 'subsystem == "com.markdownquicklook.app" OR process == "Markdown" OR eventMessage CONTAINS "WebContent"' --level debug --style compact > "$LOG_FILE" &
LOG_PID=$!

echo "Finding App..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/MarkdownPreviewEnhanced-*/Build/Products/Release -name "Markdown Preview Enhanced.app" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "App not found in Release. Trying Debug..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/MarkdownPreviewEnhanced-*/Build/Products/Debug -name "Markdown Preview Enhanced.app" | head -1)
fi

if [ -z "$APP_PATH" ]; then
    echo "App not found. Please build first."
    kill $LOG_PID
    exit 1
fi

echo "Launching App: $APP_PATH"
open "$APP_PATH"

echo "Waiting for crash/load (10s)..."
sleep 10

echo "Stopping Log Stream..."
kill $LOG_PID

echo "Analyzing Logs..."
grep -i "error" "$LOG_FILE"
grep -i "fault" "$LOG_FILE"
grep -i "terminated" "$LOG_FILE"
grep -i "MarkdownWebView" "$LOG_FILE"

echo "Done."
