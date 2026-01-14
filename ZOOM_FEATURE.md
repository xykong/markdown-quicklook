# Zoom Feature Implementation

## Overview
Added zoom in/out functionality for the Markdown QuickLook preview with keyboard shortcuts.

## Features
- **Zoom In**: CMD + '+' or CMD + '='
- **Zoom Out**: CMD + '-'
- **Reset Zoom**: CMD + '0'
- **Zoom Range**: 0.5x to 3.0x
- **Persistent**: Zoom level is saved and restored across sessions

## Implementation Details

### 1. Web Renderer (TypeScript)
**File**: `web-renderer/src/index.ts`

The zoom functionality is primarily handled in the web renderer for better responsiveness:

```typescript
// Keyboard event listener in the web page
document.addEventListener('keydown', (e: KeyboardEvent) => {
    if (e.metaKey || e.ctrlKey) {
        if (e.key === '+' || e.key === '=') {
            // Zoom in
        } else if (e.key === '-' || e.key === '_') {
            // Zoom out
        } else if (e.key === '0') {
            // Reset zoom
        }
    }
});
```

CSS transform is used for smooth zooming:
```typescript
outputDiv.style.transform = `scale(${level})`;
outputDiv.style.transformOrigin = 'top left';
outputDiv.style.width = `${100 / level}%`;
```

### 2. Swift Integration
**File**: `Sources/MarkdownPreview/PreviewViewController.swift`

Enhanced `InteractiveWebView` to accept keyboard focus:
```swift
class InteractiveWebView: WKWebView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
}
```

### 3. Preferences Storage
**File**: `Sources/Shared/AppearancePreference.swift`

Added persistent storage for zoom level:
```swift
public var zoomLevel: Double {
    get {
        let level = store.double(forKey: zoomLevelKey)
        return level == 0 ? 1.0 : level
    }
    set {
        store.set(newValue, forKey: zoomLevelKey)
        store.synchronize()
    }
}
```

## Usage Instructions

1. **Open a Markdown file** in QuickLook (select file and press Space in Finder)
2. **Click inside the preview window** to give it focus
3. **Use keyboard shortcuts**:
   - Press `CMD + '+'` to zoom in
   - Press `CMD + '-'` to zoom out
   - Press `CMD + '0'` to reset to default size

## Technical Notes

### Why Keyboard Events are Handled in JavaScript
QuickLook preview controllers have limited keyboard event handling because:
- The QuickLook window manages its own event routing
- The system controls window focus and first responder status
- JavaScript keyboard events in WKWebView are more reliable for this use case

### Event Flow
1. User presses keyboard shortcut
2. `keydown` event fires in the web page
3. JavaScript handler captures the event and prevents default behavior
4. Zoom level is adjusted and applied via CSS transform
5. Zoom level is logged back to Swift via the message handler
6. Swift saves the zoom level to UserDefaults for persistence

## Testing

Run the test script to verify functionality:
```bash
./test-zoom.sh
```

Or manually test:
```bash
qlmanage -p test-zoom.md
```

Then click in the window and try the keyboard shortcuts.

## Troubleshooting

### Keyboard shortcuts not working?
1. **Ensure the preview window has focus**: Click inside the preview area
2. **Check logs**: Run `./debug-extension.sh` to see log output
3. **Verify installation**: The app should be installed at `/Applications/Markdown Preview Enhanced.app`

### Zoom not persisting?
- Check UserDefaults: The zoom level should be stored in the app group
- Logs should show "Zoom level set to X" messages

## Future Enhancements
- Add visual zoom indicator (e.g., percentage display)
- Support trackpad pinch-to-zoom gesture
- Add menu items for zoom controls
