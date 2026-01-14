import Foundation
import SwiftUI
import AppKit

public enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    public var nsAppearance: NSAppearance? {
        switch self {
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        case .system: return nil // System handles it (nil implies inherited)
        }
    }
}

public class AppearancePreference: ObservableObject {
    public static let shared = AppearancePreference()
    
    // Key for UserDefaults
    private let key = "preferredAppearanceMode"
    private let quickLookSizeKey = "quickLookWindowSize"
    private let hostWindowFrameKey = "hostWindowFrame"
    private let zoomLevelKey = "markdownZoomLevel"
    
    // The App Group Identifier
    // IMPORTANT: You must enable "App Groups" in Xcode Signing & Capabilities for BOTH targets
    // and add "group.com.xykong.Markdown" (or your own ID) to the list.
    public static let appGroupIdentifier = "group.com.xykong.Markdown"
    
    // Use UserDefaults directly instead of @AppStorage to support conditional App Group
    public var currentMode: AppearanceMode {
        get {
            let raw = store.string(forKey: key) ?? AppearanceMode.light.rawValue
            return AppearanceMode(rawValue: raw) ?? .light
        }
        set {
            objectWillChange.send()
            store.set(newValue.rawValue, forKey: key)
        }
    }
    
    public var hostWindowFrame: CGRect? {
        get {
            guard let dict = store.dictionary(forKey: hostWindowFrameKey) else { return nil }
            let x = dict["x"] as? Double ?? 0
            let y = dict["y"] as? Double ?? 0
            let w = dict["w"] as? Double ?? 0
            let h = dict["h"] as? Double ?? 0
            return CGRect(x: x, y: y, width: w, height: h)
        }
        set {
            if let v = newValue {
                store.set(["x": v.origin.x, "y": v.origin.y, "w": v.width, "h": v.height], forKey: hostWindowFrameKey)
            } else {
                store.removeObject(forKey: hostWindowFrameKey)
            }
            store.synchronize()
        }
    }
    
    public var quickLookSize: CGSize? {
        get {
            guard let dict = store.dictionary(forKey: quickLookSizeKey) else { return nil }
            
            let w = dict["w"] as? Double ?? 0
            let h = dict["h"] as? Double ?? 0
            
            if w > 0 && h > 0 {
                return CGSize(width: w, height: h)
            }
            return nil
        }
        set {
            if let v = newValue {
                store.set(["w": Double(v.width), "h": Double(v.height)], forKey: quickLookSizeKey)
            } else {
                store.removeObject(forKey: quickLookSizeKey)
            }
            // Force sync to disk immediately to ensure persistence across process restarts
            store.synchronize()
        }
    }
    
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
    
    private let store: UserDefaults
    
    public init() {
        // Try to load from App Group, fallback to standard
        if let sharedStore = UserDefaults(suiteName: AppearancePreference.appGroupIdentifier) {
            self.store = sharedStore
        } else {
            self.store = UserDefaults.standard
        }
    }
    
    // Helper to apply appearance to a view
    public func apply(to view: NSView) {
        if let appearance = currentMode.nsAppearance {
            view.appearance = appearance
        } else {
            view.appearance = nil // Reset to system
        }
    }
}
