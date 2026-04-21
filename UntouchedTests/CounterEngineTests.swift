import XCTest
@testable import Untouched

final class CounterEngineTests: XCTestCase {

    // MARK: - daysUntouched

    func testDaysUntouchedZeroOnSameDay() {
        let start = date("2026-04-21 10:00")
        let now = date("2026-04-21 22:00")
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now), 0)
    }

    func testDaysUntouchedAfterOneDay() {
        let start = date("2026-04-21 23:59")
        let now = date("2026-04-22 00:01")
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now), 1)
    }

    func testDaysUntouchedAcrossDSTForward() {
        // US: 2026-03-08 02:00 → 03:00 (spring forward, day loses an hour)
        let cal = usCalendar()
        let start = parse("2026-03-07 10:00", calendar: cal)
        let now = parse("2026-03-10 10:00", calendar: cal)
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now, calendar: cal), 3)
    }

    func testDaysUntouchedAcrossDSTBack() {
        // US: 2026-11-01 02:00 → 01:00 (fall back, day gains an hour)
        let cal = usCalendar()
        let start = parse("2026-10-31 10:00", calendar: cal)
        let now = parse("2026-11-03 10:00", calendar: cal)
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now, calendar: cal), 3)
    }

    func testDaysUntouchedAfterLongGap() {
        let start = date("2025-04-21 10:00")
        let now = date("2026-04-21 10:00")
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now), 365)
    }

    func testDaysUntouchedNeverNegative() {
        let start = date("2026-04-22 10:00")
        let now = date("2026-04-21 10:00")
        XCTAssertEqual(CounterEngine.daysUntouched(from: start, to: now), 0)
    }

    // MARK: - Milestone detection

    func testNoMilestonesBelowDay1() {
        let counter = makeCounter(startedDaysAgo: 0)
        XCTAssertTrue(CounterEngine.unearnedMilestones(for: counter).isEmpty)
    }

    func testDay1UnlocksAtDay1() {
        let counter = makeCounter(startedDaysAgo: 1)
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        XCTAssertEqual(unearned.first?.dayValue, 1)
    }

    func testMultipleMilestonesUnlockOldestFirst() {
        // First open on day 10 → both .day1 and .week1 unearned.
        let counter = makeCounter(startedDaysAgo: 10)
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        XCTAssertEqual(unearned.map(\.dayValue), [1, 7])
    }

    func testAlreadyEarnedMilestonesSkipped() {
        let counter = makeCounter(startedDaysAgo: 10)
        counter.earnedCoins.append(earnedCoin(dayValue: 1))
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        XCTAssertEqual(unearned.map(\.dayValue), [7])
    }

    func testYearlyMilestonesGeneratePastYear1() {
        // 800 days comfortably crosses year 2 (calendar year lengths vary).
        let counter = makeCounter(startedDaysAgo: 800)
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        XCTAssertEqual(unearned.map(\.dayValue), [1, 7, 30, 60, 90, 180, 270, 365, 730])
    }

    func testProgressionCapsAtYearly3() {
        // Four years in — all nine coins unlocked, no further milestones.
        let counter = makeCounter(startedDaysAgo: 365 * 4 + 10)
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        let last = unearned.last
        XCTAssertEqual(last, .yearly(3))
        XCTAssertEqual(unearned.count, 9)
    }

    // MARK: - nextMilestone

    func testNextMilestoneAtDay0IsDay1() {
        let counter = makeCounter(startedDaysAgo: 0)
        let next = CounterEngine.nextMilestone(for: counter)
        XCTAssertEqual(next?.milestone.dayValue, 1)
        XCTAssertEqual(next?.daysRemaining, 1)
    }

    func testNextMilestonePastYear1IsYear2() {
        let counter = makeCounter(startedDaysAgo: 400)
        let next = CounterEngine.nextMilestone(for: counter)
        XCTAssertEqual(next?.milestone, .yearly(2))
    }

    func testNextMilestoneNilPastFinalCoin() {
        let counter = makeCounter(startedDaysAgo: 365 * 4)
        XCTAssertNil(CounterEngine.nextMilestone(for: counter))
    }

    // MARK: - Progress

    func testProgressHalfway() {
        // Calendar-based: halfway between month1 target and month2 target.
        // Calendar months vary (28–31 days), so accept a loose tolerance.
        let counter = makeCounter(startedDaysAgo: 45)
        let p = CounterEngine.progressToNextMilestone(for: counter)
        XCTAssertEqual(p, 0.5, accuracy: 0.1)
    }

    func testProgressClampedBetween0And1() {
        let p1 = CounterEngine.progressToNextMilestone(for: makeCounter(startedDaysAgo: 0))
        XCTAssert((0.0...1.0).contains(p1))
        let p2 = CounterEngine.progressToNextMilestone(for: makeCounter(startedDaysAgo: 1000))
        XCTAssert((0.0...1.0).contains(p2))
    }

    func testProgressIsFullPastFinalCoin() {
        let counter = makeCounter(startedDaysAgo: 365 * 4)
        XCTAssertEqual(CounterEngine.progressToNextMilestone(for: counter), 1.0)
    }

    // MARK: - Calendar-aware unlocks

    func testMonth1UnlocksOnCalendarMonthBoundary() {
        let cal = Calendar(identifier: .gregorian)
        let start = parse("2026-01-15 10:00", calendar: cal)
        let justBefore = parse("2026-02-14 23:59", calendar: cal)
        let justAfter = parse("2026-02-15 00:01", calendar: cal)
        XCTAssertFalse(Milestone.unlocked(from: start, to: justBefore, calendar: cal).contains(.month1))
        XCTAssertTrue(Milestone.unlocked(from: start, to: justAfter, calendar: cal).contains(.month1))
    }

    func testMonth1OnJan31ClampsToFeb28() {
        // Calendar clamps Jan 31 + 1 month to Feb 28/29 — the milestone hits
        // the last day of February, not a fixed day-30 offset.
        let cal = Calendar(identifier: .gregorian)
        let start = parse("2026-01-31 10:00", calendar: cal)
        let feb28 = parse("2026-02-28 12:00", calendar: cal)
        XCTAssertTrue(Milestone.unlocked(from: start, to: feb28, calendar: cal).contains(.month1))
    }

    // MARK: - Helpers

    private func makeCounter(startedDaysAgo days: Int) -> Counter {
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return Counter(name: "test", startDate: start)
    }

    private func earnedCoin(dayValue: Int) -> EarnedCoin {
        EarnedCoin(dayValue: dayValue, earnedDate: Date(), runStartDate: Date())
    }

    private func date(_ s: String) -> Date {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withSpaceBetweenDateAndTime, .withColonSeparatorInTime, .withTime]
        f.timeZone = .current
        // Fallback parser — use a plain date formatter for flexibility.
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.timeZone = .current
        return df.date(from: s) ?? Date()
    }

    private func parse(_ s: String, calendar: Calendar) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.calendar = calendar
        df.timeZone = calendar.timeZone
        return df.date(from: s) ?? Date()
    }

    private func usCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York") ?? .current
        return cal
    }
}
