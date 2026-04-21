import Foundation

/// Pure functions for day math, milestone detection, and reset logic.
/// No stored state. Must be testable without SwiftData.
enum CounterEngine {
    /// Days untouched — always computed from two dates, never stored.
    /// Storing an integer drifts across timezones, DST, and device-asleep gaps.
    static func daysUntouched(
        from start: Date,
        to reference: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let s = calendar.startOfDay(for: start)
        let r = calendar.startOfDay(for: reference)
        return max(0, calendar.dateComponents([.day], from: s, to: r).day ?? 0)
    }

    static func daysUntouched(for counter: Counter, calendar: Calendar = .current) -> Int {
        daysUntouched(from: counter.startDate, calendar: calendar)
    }

    /// All milestones the counter has crossed but not yet earned, oldest first.
    /// On first app open in days, this may return multiple coins — present them
    /// one at a time (SPEC §12: "oldest first").
    static func unearnedMilestones(for counter: Counter, now: Date = Date()) -> [Milestone] {
        let days = daysUntouched(from: counter.startDate, to: now)
        let earned = Set(counter.earnedCoins.map(\.dayValue))
        return Milestone.upTo(days: days).filter { !earned.contains($0.dayValue) }
    }

    /// Next milestone the counter is working toward. `nil` only if days is
    /// astronomically large (never expected in practice).
    static func nextMilestone(for counter: Counter, now: Date = Date()) -> (Milestone, daysRemaining: Int)? {
        let days = daysUntouched(from: counter.startDate, to: now)
        if let m = Milestone.fixedCases.first(where: { $0.dayValue > days }) {
            return (m, m.dayValue - days)
        }
        // Past year 1 — next yearly coin.
        let nextYear = (days / 365) + 1
        let m = Milestone.yearly(nextYear)
        return (m, m.dayValue - days)
    }

    /// Progress 0.0–1.0 from previous milestone to the next one.
    static func progressToNextMilestone(for counter: Counter, now: Date = Date()) -> Double {
        let days = daysUntouched(from: counter.startDate, to: now)
        let milestones = Milestone.upTo(days: days)
        let previousDay = milestones.last?.dayValue ?? 0
        guard let (next, _) = nextMilestone(for: counter, now: now) else { return 0 }
        let span = max(1, next.dayValue - previousDay)
        let progress = Double(days - previousDay) / Double(span)
        return min(1.0, max(0.0, progress))
    }
}
