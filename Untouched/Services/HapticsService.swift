import UIKit

enum HapticsService {
    static var enabled: Bool = true

    static func selection() {
        guard enabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func heavy() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func medium() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Coin earned: success + delayed medium impact (SPEC §6).
    static func coinEarned() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { medium() }
    }
}
