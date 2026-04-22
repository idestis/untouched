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

    /// Schedule the big milestone notification. Louder and taller than the
    /// daily line: title + body + sound, so the system renders it as a
    /// two-line banner instead of a single-line nudge.
    static func scheduleMilestone(date: Date, days: Int, counterId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = Milestone(dayValue: days).map { Copy.Milestones.title(for: $0) }
            ?? Copy.Notification.milestone(day: days)
        content.body = Copy.CoinEarned.tapToEngrave
        content.interruptionLevel = .active
        content.sound = .default
        // Groups per-counter so iOS stacks milestones from the same counter
        // together in the notification center.
        content.threadIdentifier = "\(milestonePrefix)\(counterId.uuidString)"

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let id = "\(milestonePrefix)\(counterId.uuidString).\(days)"
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    /// Clear any previously-scheduled milestones for this counter and schedule
    /// fresh ones for every future milestone on the shelf horizon. Idempotent
    /// — safe to call on any state change (counter created, reset, backfill).
    static func scheduleMilestones(for counter: Counter, now: Date = Date()) {
        cancelMilestones(for: counter.id)
        for milestone in Milestone.shelfHorizon {
            let target = milestone.targetDate(from: counter.startDate)
            guard target > now else { continue }
            scheduleMilestone(date: target, days: milestone.dayValue, counterId: counter.id)
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
