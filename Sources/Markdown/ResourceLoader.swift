import Foundation

struct ResourceLoader {
    static func findIndexHtml(in bundle: Bundle = .main) -> URL? {
        if let url = bundle.url(forResource: "index", withExtension: "html", subdirectory: "WebRenderer") {
            return url
        } else if let url = bundle.url(forResource: "index", withExtension: "html", subdirectory: "dist") {
            return url
        } else if let url = bundle.url(forResource: "index", withExtension: "html") {
            return url
        }
        return nil
    }
}
