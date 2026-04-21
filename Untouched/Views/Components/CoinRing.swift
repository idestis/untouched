import SwiftUI

/// The signature motif. Earned coins are amber-bordered with a soft fill and
/// glow. Locked coins are dashed-outlined. Never animate a static coin — SPEC §6.
struct CoinRing: View {
    enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 56
            case .medium: return 96
            case .large: return 156
            }
        }

        var numberFont: Font {
            switch self {
            case .small: return .utSmallCoinNumber
            case .medium: return .system(size: 24, weight: .medium)
            case .large: return .utCoinNumber
            }
        }

        var strokeWidth: CGFloat {
            switch self {
            case .small: return 1
            case .medium: return 1.25
            case .large: return 1.5
            }
        }
    }

    enum LabelStyle { case number, milestone }

    let value: Int
    let earned: Bool
    var size: Size = .medium
    var glow: Bool = true
    var labelStyle: LabelStyle = .number

    private var displayText: String {
        switch labelStyle {
        case .number:
            return "\(value)"
        case .milestone:
            return Milestone(dayValue: value)?.shortLabel ?? "\(value)"
        }
    }

    var body: some View {
        ZStack {
            if earned {
                Circle()
                    .fill(Color.utAmberSoft)
                Circle()
                    .strokeBorder(Color.utAmber, lineWidth: size.strokeWidth)
            } else {
                Circle()
                    .strokeBorder(
                        Color.utCoinLockedBorder,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
            }

            Text(displayText)
                .font(size.numberFont)
                .foregroundStyle(earned ? Color.utAmber : Color.utTextTertiary)
                .monospacedDigit()
        }
        .frame(width: size.dimension, height: size.dimension)
        .shadow(
            color: earned && glow ? Color.utAmberGlow : .clear,
            radius: earned && glow && size == .large ? 50 : 0
        )
    }
}
