import WidgetKit
import SwiftUI

struct HomeMediumWidget: Widget {
    let kind = "HomeMedium"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CounterSelectionIntent.self,
            provider: UntouchedProvider()
        ) { entry in
            HomeMediumView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Untouched — Medium")
        .description("Name, day count, and progress to the next coin.")
        .supportedFamilies([.systemMedium])
    }
}

private struct HomeMediumView: View {
    let entry: UntouchedEntry

    private let amber = Color(hex: "EF9F27")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Copy.Widget.brand)
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("\(entry.counterName).")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Spacer()
                if let last = entry.lastEarnedDays {
                    lastCoinRing(days: last)
                }
            }

            Spacer(minLength: 8)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(entry.days)")
                    .font(.system(size: 64, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(Copy.Widget.daysSuffix)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
            }

            if entry.nextMilestoneDays != nil {
                Spacer(minLength: 8)
                segmentedBar(progress: entry.windowProgress)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func lastCoinRing(days: Int) -> some View {
        Text(Copy.Widget.dShort(days))
            .font(.system(size: 12, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(amber)
            .frame(width: 44, height: 44)
            .overlay(Circle().strokeBorder(amber, lineWidth: 1))
    }

    private func segmentedBar(progress: Double, segments: Int = 10) -> some View {
        let clamped = max(0, min(1, progress))
        let filled = Int((clamped * Double(segments)).rounded(.down))
        return HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { i in
                Capsule()
                    .fill(i < filled ? amber : Color.white.opacity(0.08))
                    .frame(height: 4)
            }
        }
    }
}
