import SwiftUI

extension Font {
    static let utMega         = Font.system(size: 120, weight: .medium)
    static let utMegaMedium   = Font.system(size: 96, weight: .medium)
    static let utMegaSmall    = Font.system(size: 76, weight: .medium)

    static func utMegaCount(digits: Int) -> (font: Font, tracking: CGFloat) {
        switch digits {
        case ...3: return (.utMega, -6)
        case 4:    return (.utMegaMedium, -5)
        default:   return (.utMegaSmall, -4)
        }
    }
    static let utScreenTitle  = Font.system(size: 48, weight: .medium)
    static let utH1           = Font.system(size: 34, weight: .medium)
    static let utNameDisplay  = Font.system(size: 40, weight: .medium)
    static let utBody         = Font.system(size: 15, weight: .regular)
    static let utBodyMedium   = Font.system(size: 15, weight: .medium)
    static let utLabel        = Font.system(size: 10, weight: .medium)
    static let utChip         = Font.system(size: 11, weight: .medium)
    static let utCoinNumber   = Font.system(size: 44, weight: .medium)
    static let utSmallCoinNumber = Font.system(size: 18, weight: .medium)
}
