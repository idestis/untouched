import WidgetKit
import SwiftUI

struct HomeMediumWidget: Widget {
    let kind = "HomeMedium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UntouchedProvider()) { entry in
            HomeMediumView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Untouched — Medium")
        .description("Day count, progress, last earned coin.")
        .supportedFamilies([.systemMedium])
    }
}

private struct HomeMediumView: View {
    let entry: UntouchedEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.counterName.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(Color(hex: "EF9F27"))
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(entry.days)")
                    .font(.system(size: 56, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text("days")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                if let last = entry.lastEarnedDays {
                    lastCoinChip(days: last)
                }
            }

            if let next = entry.nextMilestoneDays {
                progressBar(days: entry.days, next: next)
                HStack {
                    Text("\(entry.days)d")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text("\(next)d")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func lastCoinChip(days: Int) -> some View {
        Text("\(days)")
            .font(.system(size: 11, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(Color(hex: "EF9F27"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                Capsule().strokeBorder(Color(hex: "EF9F27"), lineWidth: 1)
            )
    }

    private func progressBar(days: Int, next: Int) -> some View {
        let progress = max(0, min(1, Double(days) / Double(next)))
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.08))
                Capsule()
                    .fill(Color(hex: "EF9F27"))
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 3)
    }
}
