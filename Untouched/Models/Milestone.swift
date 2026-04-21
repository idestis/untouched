import Foundation

/// Day-count milestones. Fixed cases up to one year; yearly coins after that.
///
/// Stored on `EarnedCoin` as the `dayValue` Int — the enum is a helper layer,
/// never the source of truth. This keeps SwiftData happy (no associated-value
/// enums as stored properties) and makes the yearly extension trivial.
enum Milestone: Equatable, Hashable {
    case day1
    case week1
    case month1
    case month2
    case month3
    case month6
    case month9
    case year1
    case yearly(Int) // year 2+, stored as n where days = n * 365

    var dayValue: Int {
        switch self {
        case .day1:         return 1
        case .week1:        return 7
        case .month1:       return 30
        case .month2:       return 60
        case .month3:       return 90
        case .month6:       return 180
        case .month9:       return 270
        case .year1:        return 365
        case .yearly(let n): return n * 365
        }
    }

    /// All fixed milestones, ordered by day. Yearly cases are generated
    /// on demand based on the current day count — see `upTo(days:)`.
    static let fixedCases: [Milestone] = [
        .day1, .week1, .month1, .month2, .month3, .month6, .month9, .year1,
    ]

    /// Every milestone up to and including `days`, ordered oldest first.
    /// Includes the fixed cases plus any yearly cases past year 1.
    static func upTo(days: Int) -> [Milestone] {
        var out = fixedCases.filter { $0.dayValue <= days }
        var n = 2
        while n * 365 <= days {
            out.append(.yearly(n))
            n += 1
        }
        return out
    }

    /// Compact label for coin faces: "24h", "7d", "30d", "6mo", "1y", "2y".
    var shortLabel: String {
        switch self {
        case .day1:          return "24h"
        case .week1:         return "7d"
        case .month1:        return "30d"
        case .month2:        return "60d"
        case .month3:        return "90d"
        case .month6:        return "6mo"
        case .month9:        return "9mo"
        case .year1:         return "1y"
        case .yearly(let n): return "\(n)y"
        }
    }

    /// Build from a stored `dayValue` (the integer persisted on `EarnedCoin`).
    init?(dayValue: Int) {
        for c in Self.fixedCases where c.dayValue == dayValue {
            self = c
            return
        }
        if dayValue > 365, dayValue % 365 == 0 {
            self = .yearly(dayValue / 365)
            return
        }
        return nil
    }
}
