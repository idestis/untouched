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

    /// Schedule the optional daily check-in at the user-picked time. One a day.
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

    /// Silent passive notification at midnight of a milestone day so widgets
    /// refresh to reflect the new coin. Never sounds, never pings.
    static func scheduleSilentMilestone(date: Date, days: Int) {
        let content = UNMutableNotificationContent()
        content.body = Copy.Notification.milestone(day: days)
        content.interruptionLevel = .passive
        content.sound = nil

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let id = "\(milestonePrefix)\(days)"
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
