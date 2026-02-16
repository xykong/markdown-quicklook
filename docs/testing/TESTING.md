# Testing Guide

## Local Verification (本地验证)

### Step 1: Build the App
```bash
make app
```

### Step 2: Run the Host App
After build succeeds, run:
```bash
open ~/Library/Developer/Xcode/DerivedData/MarkdownQuickLook-*/Build/Products/Debug/MarkdownQuickLook.app
```

Or in Xcode:
1. Open `MarkdownQuickLook.xcodeproj`
2. **重要**: 在顶部工具栏确保选择的是 **MarkdownQuickLook** scheme (不是 MarkdownPreview)
   - 点击 scheme 下拉菜单（在 Run/Stop 按钮旁边）
   - 选择 "MarkdownQuickLook"
3. Press `Cmd+R` to run
4. 如果弹出 "Choose an app to run"，选择任意应用（如 Finder），这是 Extension 的正常行为

**Important**: Keep the app running while testing. This registers the Quick Look extension with the system.

### Step 3: Reset Quick Look Cache
```bash
qlmanage -r
qlmanage -r cache
```

### Step 4: Test with a Markdown File
1. Create or select a `.md` file in Finder
2. Press **Space** to trigger Quick Look
3. Verify the rendering

## Test Cases

### Test File: `tests/fixtures/test-sample.md`
This file verifies all core features:

```markdown
# Markdown Quick Look Test

## Basic Markdown
**Bold**, *Italic*, ~~Strikethrough~~

## Code Block
\`\`\`javascript
const hello = () => {
  console.log("Hello, World!");
};
\`\`\`

## Math (KaTeX)
Inline: $E=mc^2$

Block:
$$
\\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
$$

## Mermaid Diagram
\`\`\`mermaid
graph TD;
    A[Start] --> B{Is it working?};
    B -->|Yes| C[Great!];
    B -->|No| D[Debug];
\`\`\`

## Task List
- [x] Build project
- [x] Run tests
- [ ] Deploy
```

## Feature-Specific Testing

### Zoom Feature Testing

#### Quick Test

1. **Open the test file**:
   ```bash
   cd /path/to/markdown-quicklook
   open -a Finder tests/fixtures/test-zoom.md
   ```

2. **Preview with QuickLook**:
   - Select `test-zoom.md` in Finder
   - Press `Space` to open QuickLook preview

3. **Test zoom methods**:
   
   **Method 1: Keyboard shortcuts**
   - Try pressing `CMD + '+'` (zoom in)
   - Try pressing `CMD + '-'` (zoom out)
   - Try pressing `CMD + '0'` (reset)
   
   **Method 2: Mouse wheel zoom (RECOMMENDED)**
   - Hold `CMD` key
   - Scroll up/down with mouse wheel or trackpad
   - This should work more reliably in QuickLook
   
   **Method 3: Pinch gesture**
   - Use two-finger pinch on trackpad
   - Pinch out to zoom in, pinch in to zoom out

#### Debug with Logs

Run the debug script to see what's happening:

```bash
./tests/scripts/debug-zoom.sh
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

#### Expected Behavior

**In Host App** (works):
- Keyboard shortcuts work correctly
- Mouse wheel zoom works
- Pinch gesture works
- Zoom is applied and persisted

**In QuickLook Preview** (partial):
- Mouse wheel zoom and pinch gestures work reliably
- Keyboard shortcuts may be intercepted by system
- Focus handling may require clicking in the window first

### Auto-Refresh Testing

Test file: `tests/fixtures/test-auto-refresh.md`

1. Open file in QuickLook
2. Edit the file and save
3. Preview should automatically refresh without closing

## Debug Tools

### View Extension Logs

Stream logs from the extension in real-time:

```bash
./tests/scripts/debug-extension.sh
```

Or manually:
```bash
log stream --predicate 'subsystem contains "com.markdownquicklook"' --level debug
```

### Verify Extension Installation

Check if the extension is registered:

```bash
./tests/scripts/verify-extension.sh
```

Or manually:
```bash
qlmanage -m | grep -i markdown
```

### Check Keyboard Event Handling

Test file: `tests/fixtures/check-keyboard.html`

A simple HTML page that logs keyboard events for debugging purposes.

## Troubleshooting

### Extension not loading?
1. Check if the app is running
2. Run `qlmanage -m` to list registered extensions
3. Look for `MarkdownPreview.appex`

### Old version cached?
```bash
killall Finder
qlmanage -r
qlmanage -r cache
```

### Zoom shortcuts not working?
1. Click inside the preview window first to give it focus
2. Check logs to see if events are being captured
3. Try with the Host App first to verify it works there
4. Use mouse wheel zoom (CMD + scroll) or pinch gesture as alternative

### No log output?
- Make sure the app is installed: `/Applications/FluxMarkdown.app`
- Check if the process is running: `ps aux | grep MarkdownPreview`

### Still not working?
The issue may be that QuickLook system intercepts CMD+key combinations before they reach the extension. This is a known limitation. Use alternative input methods:
1. Mouse wheel zoom (CMD + scroll) - Most reliable
2. Pinch gesture - Natural for macOS users
3. Use the Host App directly for full keyboard shortcut support

## Test Scripts Reference

All test scripts are located in `tests/scripts/`:

| Script | Purpose |
|--------|---------|
| `debug-extension.sh` | Stream logs from QuickLook extension |
| `debug-zoom.sh` | Test zoom feature with real-time logs |
| `verify-extension.sh` | Check if extension is properly installed |
| `test-zoom.sh` | Automated zoom feature testing |

## Test Fixtures Reference

All test files are located in `tests/fixtures/`:

| File | Purpose |
|------|---------|
| `test-sample.md` | General feature testing |
| `test-zoom.md` | Zoom functionality testing |
| `test-auto-refresh.md` | Auto-refresh feature testing |
| `check-keyboard.html` | Keyboard event debugging |
