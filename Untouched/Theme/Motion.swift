import SwiftUI

enum Motion {
    static let utDefault: Animation = .easeInOut(duration: 0.25)
    static let utDayRollover: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let utCoinEnter: Animation = .easeOut(duration: 0.6)
    static let utTextFade: Animation = .easeOut(duration: 0.3)
}

extension AnyTransition {
    static let utScreen: AnyTransition = .asymmetric(
        insertion: .opacity.combined(with: .offset(y: 12)),
        removal: .opacity
    )
}
