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
        let counter = makeCounter(startedDaysAgo: 730) // 2 years
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        // All fixed cases plus year2.
        XCTAssertEqual(unearned.map(\.dayValue), [1, 7, 30, 60, 90, 180, 270, 365, 730])
    }

    // MARK: - nextMilestone

    func testNextMilestoneAtDay0IsDay1() {
        let counter = makeCounter(startedDaysAgo: 0)
        let next = CounterEngine.nextMilestone(for: counter)
        XCTAssertEqual(next?.0.dayValue, 1)
        XCTAssertEqual(next?.daysRemaining, 1)
    }

    func testNextMilestonePastYear1IsYear2() {
        let counter = makeCounter(startedDaysAgo: 400)
        let next = CounterEngine.nextMilestone(for: counter)
        XCTAssertEqual(next?.0.dayValue, 730)
    }

    // MARK: - Progress

    func testProgressHalfway() {
        // day 45 between .month1 (30) and .month2 (60) → 15/30 = 0.5
        let counter = makeCounter(startedDaysAgo: 45)
        let p = CounterEngine.progressToNextMilestone(for: counter)
        XCTAssertEqual(p, 0.5, accuracy: 0.01)
    }

    func testProgressClampedBetween0And1() {
        let p1 = CounterEngine.progressToNextMilestone(for: makeCounter(startedDaysAgo: 0))
        XCTAssert((0.0...1.0).contains(p1))
        let p2 = CounterEngine.progressToNextMilestone(for: makeCounter(startedDaysAgo: 1000))
        XCTAssert((0.0...1.0).contains(p2))
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
