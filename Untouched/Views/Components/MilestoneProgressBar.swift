import SwiftUI

/// Thin amber bar from previous milestone → next milestone.
/// Day count bridge under the mega number on Today.
struct MilestoneProgressBar: View {
    /// 0.0 to 1.0 from previous to next milestone.
    let progress: Double
    /// Label like "30d" → "60d" at the two ends (optional).
    var leadingLabel: String? = nil
    var trailingLabel: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.utSurface)
                    Capsule()
                        .fill(Color.utAmber)
                        .frame(width: max(0, min(1, progress)) * geo.size.width)
                }
            }
            .frame(height: 3)

            if leadingLabel != nil || trailingLabel != nil {
                HStack {
                    if let l = leadingLabel {
                        Text(l).font(.utLabel).foregroundStyle(Color.utTextTertiary).tracking(1.5)
                    }
                    Spacer()
                    if let t = trailingLabel {
                        Text(t).font(.utLabel).foregroundStyle(Color.utTextTertiary).tracking(1.5)
                    }
                }
            }
        }
    }
}
