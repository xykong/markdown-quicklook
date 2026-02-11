#!/bin/bash

echo "=========================================="
echo "Watching for link click events..."
echo "Press Ctrl+C to stop"
echo "=========================================="
echo ""

log stream --predicate 'subsystem == "com.markdownquicklook.app" AND (message CONTAINS "Link clicked" OR message CONTAINS "Opening" OR message CONTAINS "Base URL")' --level debug --style compact
