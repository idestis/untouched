import SwiftUI
import UIKit

extension Color {
    static let utBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            : UIColor(red: 0.969, green: 0.953, blue: 0.918, alpha: 1) // #f7f3ea
    })

    static let utSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.04)
            : UIColor.black.withAlphaComponent(0.035)
    })

    static let utBorder = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.08)
    })

    static let utTextPrimary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : .black
    })

    static let utTextSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.5)
            : UIColor.black.withAlphaComponent(0.55)
    })

    static let utTextTertiary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.4)
            : UIColor.black.withAlphaComponent(0.4)
    })

    static let utAmber      = Color(hex: "EF9F27")
    static let utAmberDim   = Color(hex: "b8782f")
    static let utAmberSoft  = Color(hex: "EF9F27").opacity(0.15)
    static let utAmberGlow  = Color(hex: "EF9F27").opacity(0.25)
    static let utDanger     = Color(hex: "E24B4A")
    static let utSuccess    = Color(hex: "97C459")
}

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)

        let r, g, b, a: Double
        switch trimmed.count {
        case 6:
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
            a = 1
        case 8:
            r = Double((value & 0xFF000000) >> 24) / 255
            g = Double((value & 0x00FF0000) >> 16) / 255
            b = Double((value & 0x0000FF00) >> 8) / 255
            a = Double(value & 0x000000FF) / 255
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
