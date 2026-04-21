import SwiftUI

/// Radial pink-magenta wash behind earned coins. The single place this hue
/// appears. In dark mode it's the bright signature halo the motif was designed
/// for; in light mode it dials down to a subtle warm blush so the cream
/// background stays cream instead of turning salmon.
struct CoinAura: View {
    enum Intensity { case strong, soft }

    @Environment(\.colorScheme) private var colorScheme

    var intensity: Intensity = .strong

    var body: some View {
        RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 40,
            endRadius: endRadius
        )
    }

    private var endRadius: CGFloat {
        colorScheme == .dark ? darkRadius : lightRadius
    }

    private var darkRadius: CGFloat {
        intensity == .strong ? 440 : 420
    }

    private var lightRadius: CGFloat {
        intensity == .strong ? 300 : 280
    }

    private var colors: [Color] {
        let base: (inner: Double, mid: Double, outer: Double, fade: Double)
        switch (colorScheme, intensity) {
        case (.dark, .strong):
            base = (0.70, 0.55, 0.45, 0.25)
        case (.dark, .soft):
            base = (0.55, 0.42, 0.35, 0.18)
        case (_, .strong):
            base = (0.28, 0.20, 0.12, 0.00)
        case (_, .soft):
            base = (0.22, 0.15, 0.08, 0.00)
        }
        return [
            Color.utCoinAuraInner.opacity(base.inner),
            Color.utCoinAuraMid.opacity(base.mid),
            Color.utCoinAuraOuter.opacity(base.outer),
            Color.utCoinAuraOuter.opacity(base.fade)
        ]
    }
}
