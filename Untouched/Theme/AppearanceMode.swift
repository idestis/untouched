import SwiftUI
import UIKit

enum AppearanceMode: Int, CaseIterable, Identifiable {
    case dark = 0
    case system = 1
    case light = 2

    var id: Int { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .dark:   return .dark
        case .system: return nil
        case .light:  return .light
        }
    }

    var label: String {
        switch self {
        case .dark:   return Copy.Settings.appearanceDark
        case .system: return Copy.Settings.appearanceSystem
        case .light:  return Copy.Settings.appearanceLight
        }
    }

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:   return .dark
        case .light:  return .light
        case .system: return .unspecified
        }
    }

    @MainActor
    static func apply(_ raw: Int) {
        let mode = AppearanceMode(rawValue: raw) ?? .dark
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = mode.uiStyle
            }
        }
    }
}
