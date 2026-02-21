## MODIFIED Requirements

### Requirement: WebView HTML Loading
The preview extension SHALL load the renderer using `WKWebView.loadFileURL(_:allowingReadAccessTo:)` pointing to `dist/index.html` within the app bundle, granting read access to the entire `dist/` directory so all JS/CSS asset chunks are resolvable.

#### Scenario: Successful file URL load
- **WHEN** `viewDidLoad` is called
- **THEN** `webView.loadFileURL(indexURL, allowingReadAccessTo: distDirURL)` is called
- **AND** the WebView navigates to the local file without error
- **AND** subsequent `renderMarkdown()` calls succeed

#### Scenario: HTML file not found
- **WHEN** `index.html` cannot be located in the app bundle
- **THEN** the WebView displays a human-readable error message
- **AND** an error is logged via `os_log`

#### Scenario: Cold-start parse time reduced
- **WHEN** the QuickLook extension opens any markdown file for the first time
- **THEN** the Layer 3 cold-start p50 latency is ≤ 120 ms (down from ~205 ms baseline)
