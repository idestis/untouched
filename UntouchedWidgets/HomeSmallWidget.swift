import WidgetKit
import SwiftUI

struct HomeSmallWidget: Widget {
    let kind = "HomeSmall"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UntouchedProvider()) { entry in
            HomeSmallView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Untouched — Small")
        .description("Name and day count.")
        .supportedFamilies([.systemSmall])
    }
}

private struct HomeSmallView: View {
    let entry: UntouchedEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.counterName.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(Color(hex: "EF9F27"))
                .lineLimit(1)
            Spacer()
            Text("\(entry.days)")
                .font(.system(size: 44, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text("days")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
