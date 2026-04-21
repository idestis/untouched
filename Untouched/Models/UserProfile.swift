import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var hasCompletedOnboarding: Bool
    var isPremiumUnlocked: Bool
    var dailyCheckInHour: Int?
    var dailyCheckInMinute: Int?
    var notificationsEnabled: Bool
    var hapticsEnabled: Bool
    var reduceAmberGlow: Bool

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        isPremiumUnlocked: Bool = false,
        dailyCheckInHour: Int? = nil,
        dailyCheckInMinute: Int? = nil,
        notificationsEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        reduceAmberGlow: Bool = false
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPremiumUnlocked = isPremiumUnlocked
        self.dailyCheckInHour = dailyCheckInHour
        self.dailyCheckInMinute = dailyCheckInMinute
        self.notificationsEnabled = notificationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.reduceAmberGlow = reduceAmberGlow
    }

    var dailyCheckInTime: DateComponents? {
        guard let h = dailyCheckInHour, let m = dailyCheckInMinute else { return nil }
        return DateComponents(hour: h, minute: m)
    }

    func setDailyCheckInTime(_ components: DateComponents?) {
        dailyCheckInHour = components?.hour
        dailyCheckInMinute = components?.minute
    }
}
