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
    static func unearnedMilestones(
        for counter: Counter,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Milestone] {
        let earned = Set(counter.earnedCoins.map(\.dayValue))
        return Milestone.unlocked(from: counter.startDate, to: now, calendar: calendar)
            .filter { !earned.contains($0.dayValue) }
    }

    /// Next milestone the counter is working toward, with the exact unlock
    /// date. `nil` once the user has crossed `yearly(maxYearlyCoin)` — past
    /// that the shelf shows "keep going" and the count continues silently.
    static func nextMilestone(
        for counter: Counter,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (milestone: Milestone, daysRemaining: Int, targetDate: Date)? {
        let today = calendar.startOfDay(for: now)
        for m in Milestone.shelfHorizon {
            let target = m.targetDate(from: counter.startDate, calendar: calendar)
            if calendar.startOfDay(for: target) > today {
                let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: target)).day ?? 0
                return (m, daysRemaining: max(0, days), targetDate: target)
            }
        }
        return nil
    }

    /// Progress 0.0–1.0 from previous milestone's target date to the next's.
    /// Returns 1.0 once the user has passed the final coin — the bar stays
    /// full rather than collapsing to empty.
    static func progressToNextMilestone(
        for counter: Counter,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        guard let nextInfo = nextMilestone(for: counter, now: now, calendar: calendar) else {
            return 1.0
        }
        let unlocked = Milestone.unlocked(from: counter.startDate, to: now, calendar: calendar)
        let previousTarget = unlocked.last?.targetDate(from: counter.startDate, calendar: calendar)
            ?? counter.startDate
        let span = max(1, nextInfo.targetDate.timeIntervalSince(previousTarget))
        let progress = now.timeIntervalSince(previousTarget) / span
        return min(1.0, max(0.0, progress))
    }
}
