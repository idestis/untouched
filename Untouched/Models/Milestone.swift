import Foundation

/// Day-count milestones. Fixed cases up to one year; yearly coins through
/// year 3. Past that, the count keeps running but no further coins are awarded
/// — the shelf switches to a "keep going" motivator instead (SPEC §5).
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
    case yearly(Int) // year 2 through maxYearlyCoin

    /// Last yearly coin awarded. Beyond this the shelf shows "keep going".
    static let maxYearlyCoin = 3

    /// Canonical integer key persisted on `EarnedCoin.dayValue`. Calendar
    /// milestones (month+, year+) use their nominal day count here purely as
    /// a stable identifier — the actual unlock date is calendar-computed per
    /// counter via `targetDate(from:)`, so a user starting mid-month earns
    /// month1 exactly one calendar month later, not on day 30.
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

    /// All fixed milestones, ordered by nominal day. Yearly cases (year 2,
    /// year 3) are appended in `shelfHorizon`.
    static let fixedCases: [Milestone] = [
        .day1, .week1, .month1, .month2, .month3, .month6, .month9, .year1,
    ]

    /// The full ordered progression shown on the shelf: fixed cases + yearly
    /// through `maxYearlyCoin`. This is the horizon; there is nothing beyond.
    static let shelfHorizon: [Milestone] =
        fixedCases + (2...maxYearlyCoin).map(Milestone.yearly)

    /// The exact date this milestone unlocks, relative to a counter's start.
    /// Calendar-aware — someone starting Jan 15 earns month1 on Feb 15,
    /// month3 on Apr 15, year1 on Jan 15 next, regardless of month length.
    /// Day and week milestones are fixed offsets.
    func targetDate(from start: Date, calendar: Calendar = .current) -> Date {
        let s = calendar.startOfDay(for: start)
        var comps = DateComponents()
        switch self {
        case .day1:          comps.day = 1
        case .week1:         comps.day = 7
        case .month1:        comps.month = 1
        case .month2:        comps.month = 2
        case .month3:        comps.month = 3
        case .month6:        comps.month = 6
        case .month9:        comps.month = 9
        case .year1:         comps.year = 1
        case .yearly(let n): comps.year = n
        }
        return calendar.date(byAdding: comps, to: s) ?? s
    }

    /// Milestones unlocked between `start` and `now`, ordered oldest first.
    static func unlocked(
        from start: Date,
        to now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Milestone] {
        let today = calendar.startOfDay(for: now)
        return shelfHorizon.filter {
            calendar.startOfDay(for: $0.targetDate(from: start, calendar: calendar)) <= today
        }
    }

    /// Compact label for coin faces: calendar units, not raw days.
    var shortLabel: String {
        switch self {
        case .day1:          return "24h"
        case .week1:         return "7d"
        case .month1:        return "1mo"
        case .month2:        return "2mo"
        case .month3:        return "3mo"
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
