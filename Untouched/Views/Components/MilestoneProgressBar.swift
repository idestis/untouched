import SwiftUI

/// Segmented amber bar showing progress from the previous milestone to the next.
struct MilestoneProgressBar: View {
    /// 0.0 to 1.0 from previous to next milestone.
    let progress: Double
    var lastLabel: String? = nil
    var nextLabel: String? = nil
    var segments: Int = 10

    var body: some View {
        VStack(spacing: 10) {
            if lastLabel != nil || nextLabel != nil {
                HStack {
                    if let lastLabel {
                        label(Copy.Today.progressLast, value: lastLabel, color: Color.utTextTertiary)
                    }
                    Spacer()
                    if let nextLabel {
                        label(Copy.Today.progressNext, value: nextLabel, color: Color.utAmber)
                    }
                }
            }
            segmentsRow
        }
    }

    private func label(_ title: String, value: String, color: Color) -> some View {
        Text("\(title) · \(value)")
            .font(.system(size: 13, weight: .medium))
            .tracking(1.8)
            .foregroundStyle(color)
    }

    private var segmentsRow: some View {
        let clamped = max(0, min(1, progress))
        let filledCount = Int((clamped * Double(segments)).rounded(.down))
        return HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { index in
                Capsule()
                    .fill(index < filledCount ? Color.utAmber : Color.utBorder)
                    .frame(height: 4)
            }
        }
    }
}
