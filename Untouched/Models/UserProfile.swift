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
    /// User has opted in to encrypted iCloud backup of earned coins. Off by default.
    var coinsBackupEnabled: Bool = false

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        isPremiumUnlocked: Bool = false,
        dailyCheckInHour: Int? = nil,
        dailyCheckInMinute: Int? = nil,
        notificationsEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        reduceAmberGlow: Bool = false,
        coinsBackupEnabled: Bool = false
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPremiumUnlocked = isPremiumUnlocked
        self.dailyCheckInHour = dailyCheckInHour
        self.dailyCheckInMinute = dailyCheckInMinute
        self.notificationsEnabled = notificationsEnabled
        self.hapticsEnabled = hapticsEnabled
        self.reduceAmberGlow = reduceAmberGlow
        self.coinsBackupEnabled = coinsBackupEnabled
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
