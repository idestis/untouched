import SwiftUI

/// Segmented amber bar showing progress from the previous milestone to the next.
struct MilestoneProgressBar: View {
    /// 0.0 to 1.0 from previous to next milestone.
    let progress: Double
    var lastDays: Int? = nil
    var nextDays: Int? = nil
    var segments: Int = 10

    var body: some View {
        VStack(spacing: 10) {
            if lastDays != nil || nextDays != nil {
                HStack {
                    if let lastDays {
                        label(Copy.Today.progressLast, value: "\(lastDays)D", color: Color.utTextTertiary)
                    }
                    Spacer()
                    if let nextDays {
                        label(Copy.Today.progressNext, value: "\(nextDays)D", color: Color.utAmber)
                    }
                }
            }
            segmentsRow
        }
    }

    private func label(_ title: String, value: String, color: Color) -> some View {
        Text("\(title) · \(value)")
            .font(.utLabel)
            .tracking(1.5)
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
