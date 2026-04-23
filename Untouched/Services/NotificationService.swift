import Foundation
import UserNotifications

enum NotificationService {
    private static let dailyId = "app.getuntouched.daily"
    private static let milestonePrefix = "app.getuntouched.milestone."

    @MainActor
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedule the optional daily check-in at the user-picked time. One a day,
    /// body-only, silent — a quiet line, not a banner with a chime.
    static func scheduleDailyCheckIn(at components: DateComponents, days: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyId])

        let content = UNMutableNotificationContent()
        content.body = Copy.Notification.dailyCheckIn(day: days)
        content.interruptionLevel = .active
        content.sound = nil

        var trigger = components
        trigger.second = 0
        let t = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)

        center.add(UNNotificationRequest(identifier: dailyId, content: content, trigger: t))
    }

    /// Default fire time when the user hasn't picked one — a civilized
    /// hour so backfilled counters (stored at start-of-day) don't page
    /// someone at midnight on their milestone day.
    static let defaultMilestoneTime = DateComponents(hour: 9, minute: 0)

    /// Schedule the big milestone notification. Louder and taller than the
    /// daily line: title + body + sound, so the system renders it as a
    /// two-line banner instead of a single-line nudge.
    private static func scheduleMilestone(at comps: DateComponents, days: Int, counterId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = Milestone(dayValue: days).map { Copy.Milestones.title(for: $0) }
            ?? Copy.Notification.milestone(day: days)
        content.body = Copy.CoinEarned.tapToEngrave
        content.interruptionLevel = .active
        content.sound = .default
        // Groups per-counter so iOS stacks milestones from the same counter
        // together in the notification center.
        content.threadIdentifier = "\(milestonePrefix)\(counterId.uuidString)"

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let id = "\(milestonePrefix)\(counterId.uuidString).\(days)"
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    /// Clear any previously-scheduled milestones for this counter and schedule
    /// fresh ones for every future milestone on the shelf horizon. Idempotent
    /// — safe to call on any state change (counter created, reset, backfill).
    ///
    /// Fires at `time` on each target calendar day — decoupled from
    /// `counter.startDate`'s hour/minute so a backfill (stored at 00:00)
    /// does not produce midnight alerts.
    static func scheduleMilestones(
        for counter: Counter,
        at time: DateComponents = defaultMilestoneTime,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        cancelMilestones(for: counter.id)
        let hour = time.hour ?? 9
        let minute = time.minute ?? 0
        for milestone in Milestone.shelfHorizon {
            let target = milestone.targetDate(from: counter.startDate, calendar: calendar)
            var comps = calendar.dateComponents([.year, .month, .day], from: target)
            comps.hour = hour
            comps.minute = minute
            guard let fireDate = calendar.date(from: comps), fireDate > now else { continue }
            scheduleMilestone(at: comps, days: milestone.dayValue, counterId: counter.id)
        }
    }

    static func cancelMilestones(for counterId: UUID) {
        let prefix = "\(milestonePrefix)\(counterId.uuidString)."
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            let ids = reqs.map(\.identifier).filter { $0.hasPrefix(prefix) }
            guard !ids.isEmpty else { return }
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    static func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
