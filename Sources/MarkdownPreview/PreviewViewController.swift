import Cocoa
import QuickLookUI
import WebKit

class PreviewViewController: NSViewController, QLPreviewingController, WKNavigationDelegate {

    var webView: WKWebView!
    var markdownContentToLoad: String?
    var isWebViewReady = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("🔵 MarkdownPreview: viewDidLoad called")
        
        // Setup WebView Configuration
        let config = WKWebViewConfiguration()
        // Allow access to local files if needed (though QL sandbox restricts this)
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        // Initialize WebView
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        
        // Add to view
        self.view.addSubview(webView)
        
        // Load the HTML bundle
        // IMPORTANT: Use Bundle(for:) instead of Bundle.main for extensions
        let bundle = Bundle(for: type(of: self))
        
        if let htmlPath = bundle.path(forResource: "dist/index", ofType: "html") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            // Allow read access to the directory containing the HTML file (for bundle.js)
            let dirURL = fileURL.deletingLastPathComponent()
            webView.loadFileURL(fileURL, allowingReadAccessTo: dirURL)
            NSLog("✅ MarkdownPreview: Loading HTML from: %@", fileURL.path)
        } else {
            NSLog("❌ MarkdownPreview: index.html NOT FOUND in bundle!")
            NSLog("   Bundle path: %@", bundle.bundlePath)
            // Fallback for debugging
            webView.loadHTMLString("<h1>Error: index.html not found. Please build the web-renderer.</h1>", baseURL: nil)
        }
    }

    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension to support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
    */

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        NSLog("🔵 MarkdownPreview: preparePreviewOfFile called for: %@", url.path)
        
        // 1. Read the file content
        do {
            let markdown = try String(contentsOf: url, encoding: .utf8)
            self.markdownContentToLoad = markdown
            NSLog("✅ MarkdownPreview: Read markdown file (%d bytes)", markdown.count)
            
            // 2. Render if ready, else wait for didFinish
            if isWebViewReady {
                NSLog("🟢 MarkdownPreview: WebView ready, rendering immediately")
                renderMarkdown(markdown)
            } else {
                NSLog("🟡 MarkdownPreview: WebView not ready, will render after load")
            }
            
            // Note: We call handler(nil) immediately because we have "accepted" the file.
            // If we wait for WebView, QL might timeout or show spinner too long.
            // Ideally, we should wait, but async JS execution is tricky to sync with this handler.
            handler(nil)
            
        } catch {
            NSLog("❌ MarkdownPreview: Failed to read file: %@", error.localizedDescription)
            handler(error)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewReady = true
        if let markdown = markdownContentToLoad {
            renderMarkdown(markdown)
            // Clear buffer to avoid re-rendering old content if view controller is reused (unlikely in QL but safe)
            markdownContentToLoad = nil
        }
    }
    
    private func renderMarkdown(_ markdown: String) {
        // Escape JSON string for JS injection
        // Using JSONEncoder is a safe way to get a valid JSON string
        guard let data = try? JSONEncoder().encode([markdown]),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        
        // jsonString is like ["...content..."], we strip [ and ]
        let innerString = String(jsonString.dropFirst().dropLast())
        
        let js = "window.renderMarkdown(\(jsonString)[0]);"
        
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("JS Error: \(error)")
            }
        }
    }
}
