# Zoom Feature Testing Instructions

## Quick Test

1. **Open the test file**:
   ```bash
   cd /Users/xykong/workspace/xykong/quicklook-project/markdown-quicklook
   open -a Finder test-zoom.md
   ```

2. **Preview with QuickLook**:
   - Select `test-zoom.md` in Finder
   - Press `Space` to open QuickLook preview

3. **Test zoom shortcuts**:
   
   **Method 1: Keyboard shortcuts**
   - Try pressing `CMD + '+'` (zoom in)
   - Try pressing `CMD + '-'` (zoom out)
   - Try pressing `CMD + '0'` (reset)
   
   **Method 2: Mouse wheel zoom (RECOMMENDED)**
   - Hold `CMD` key
   - Scroll up/down with mouse wheel or trackpad
   - This should work more reliably in QuickLook

## Debug with Logs

Run the debug script to see what's happening:

```bash
./debug-zoom.sh
```

This will:
1. Open the test file in QuickLook
2. Start monitoring logs for keyboard and zoom events
3. Show you real-time log output

Look for these log messages:
- `Local event monitor triggered` - Event captured by monitor
- `handleKeyDownEvent` - Event processed by handler
- `Zoom In/Out/Reset triggered` - Zoom function called
- `WebView keyDown` - WebView received the event
- `Zoom level set to` - JavaScript applied the zoom

## Expected Behavior

### In Host App (works)
- Keyboard shortcuts work correctly
- Zoom is applied and persisted

### In QuickLook Preview (debugging)
- Should see log messages when pressing shortcuts
- Should see zoom applied to the preview
- Focus handling may require clicking in the window first

## Troubleshooting

### No log output?
- Make sure the app is installed: `/Applications/Markdown Preview Enhanced.app`
- Check if the process is running: `ps aux | grep MarkdownPreview`

### Shortcuts not working?
- Click inside the preview window first to give it focus
- Check logs to see if events are being captured
- Try with the Host App first to verify it works there

### Still not working?
The issue may be that QuickLook system intercepts CMD+key combinations before they reach the extension. We may need to:
1. Use different keyboard shortcuts (non-CMD)
2. Add menu items for zoom
3. Use mouse/trackpad gestures instead
