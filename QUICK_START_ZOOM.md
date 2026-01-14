# Quick Start: Zoom Feature

## 🎯 How to Use Zoom

### In QuickLook Preview (Select .md file → Press Space)

**Method 1: Mouse Wheel Zoom (RECOMMENDED)**
```
Hold CMD + Scroll Up/Down
```
- Most reliable method
- Works like other Mac apps (Safari, Preview, etc.)

**Method 2: Keyboard Shortcuts**
```
CMD + '+'  or  CMD + '='    → Zoom In
CMD + '-'                    → Zoom Out
CMD + '0'                    → Reset to 100%
```
- May work depending on system configuration
- Click inside preview window first

### In Host App (Double-click .md file to open)

All methods work:
- ✅ CMD + '+'/'-'/'0'
- ✅ CMD + Scroll Wheel

## 📊 Testing

### Quick Test
```bash
cd /Users/xykong/workspace/xykong/quicklook-project/markdown-quicklook
open -a Finder test-zoom.md
# Select file and press Space
# Try: Hold CMD + Scroll, or CMD + '+'
```

### Debug Mode
```bash
./debug-zoom.sh
# Opens preview and shows real-time logs
# Press shortcuts and watch for events
```

## 🔍 Troubleshooting

### Keyboard shortcuts not working in QuickLook?
→ **Use CMD + Scroll Wheel** instead (this is normal for QuickLook)

### Nothing happens?
1. Click inside the preview window first
2. Make sure file is opened with correct app
3. Check: Right-click .md → Get Info → Open with: "Markdown Preview Enhanced"

### Still not working?
Run debug script to see logs:
```bash
./debug-zoom.sh
```

## 💡 Why Two Methods?

**QuickLook Limitation**: macOS intercepts many keyboard shortcuts for system use, especially in QuickLook windows. This is why we provide both:

1. **Keyboard shortcuts**: Work great in Host App
2. **Mouse wheel zoom**: More reliable in QuickLook (same as Preview.app, Safari, etc.)

## ✨ Features

- 🔍 Zoom range: 0.5x - 3.0x
- 💾 Auto-save: Your zoom level persists
- 🎨 Smooth scaling: CSS transform for quality
- 📱 Works everywhere: Both QuickLook and Host App
