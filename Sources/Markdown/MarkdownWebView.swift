import SwiftUI
import WebKit
import os.log

struct MarkdownWebView: NSViewRepresentable {
    var content: String
    var fileURL: URL?
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(coordinator, name: "logger")
        webConfiguration.userContentController = userContentController
        
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        #if DEBUG
        webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = coordinator
        
        var bundleURL: URL? = ResourceLoader.findIndexHtml()
        
        if let url = bundleURL {
            let dir = url.deletingLastPathComponent()
            os_log("Loading HTML from: %{public}@", log: coordinator.logger, type: .debug, url.path)
            
            do {
                var htmlContent = try String(contentsOf: url, encoding: .utf8)
                
                // Inject Debug JS
                let debugScript = """
                <script>
                window.onerror = function(msg, url, line, col, error) {
                    var extra = !col ? '' : '\\ncolumn: ' + col;
                    extra += !error ? '' : '\\nerror: ' + error;
                    var message = "Error: " + msg + "\\nurl: " + url + "\\nline: " + line + extra;
                    if(window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.logger) {
                         window.webkit.messageHandlers.logger.postMessage(message);
                    }
                };
                console.log = function(message) {
                    if(window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.logger) {
                         window.webkit.messageHandlers.logger.postMessage("JS Log: " + message);
                    }
                };
                // Verify body existence and change color to verify rendering
                document.addEventListener('DOMContentLoaded', function() {
                     if(window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.logger) {
                         window.webkit.messageHandlers.logger.postMessage("DOM Content Loaded");
                     }
                     // Optional: Visual Debug
                     // document.body.style.backgroundColor = 'lightyellow';
                });
                </script>
                """
                
                // Insert script before </head> or at the beginning if not found
                if let range = htmlContent.range(of: "</head>") {
                    htmlContent.insert(contentsOf: debugScript, at: range.lowerBound)
                } else {
                    htmlContent = debugScript + htmlContent
                }
                
                webView.loadHTMLString(htmlContent, baseURL: dir)
            } catch {
                os_log("Failed to read index.html: %{public}@", log: coordinator.logger, type: .error, error.localizedDescription)
                webView.loadFileURL(url, allowingReadAccessTo: dir)
            }
        } else {
             os_log("Failed to find index.html in bundle", log: coordinator.logger, type: .error)
        }

        
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.render(webView: webView, content: content, fileURL: fileURL)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let logger = OSLog(subsystem: "com.markdownquicklook.app", category: "MarkdownWebView")
        
        func render(webView: WKWebView, content: String, fileURL: URL?) {
            let checkJs = "typeof window.renderMarkdown"
            webView.evaluateJavaScript(checkJs) { [weak self] result, error in
                guard let self = self else { return }
                
                if let type = result as? String, type == "function" {
                    self.executeRender(webView: webView, content: content, fileURL: fileURL)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.render(webView: webView, content: content, fileURL: fileURL)
                    }
                }
            }
        }
        
        private func executeRender(webView: WKWebView, content: String, fileURL: URL?) {
            let escapedContent = content
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
            
            var options = "{}"
            if let url = fileURL {
                let baseUrlString = url.deletingLastPathComponent().path
                options = "{ \"baseUrl\": \"\(baseUrlString)\" }"
            }
            
            let js = "window.renderMarkdown(\"\(escapedContent)\", \(options));"
            
            webView.evaluateJavaScript(js) { [weak self] _, error in
                if let error = error {
                    os_log("JS Error: %{public}@", log: self?.logger ?? .default, type: .error, error.localizedDescription)
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            os_log("WebView didFinish navigation", log: logger, type: .debug)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            os_log("WebView didStartProvisionalNavigation", log: logger, type: .debug)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            os_log("WebView didFail navigation: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            os_log("WebView didFailProvisionalNavigation: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            os_log("WebView WebContent process terminated", log: logger, type: .error)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logger", let body = message.body as? String {
                os_log("JS Log: %{public}@", log: logger, type: .debug, body)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            if url.scheme == "http" || url.scheme == "https" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else if url.isFileURL && url.pathExtension == "md" {
                 NSWorkspace.shared.open(url)
                 decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
