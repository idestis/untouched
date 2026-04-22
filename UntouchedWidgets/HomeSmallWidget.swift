import WidgetKit
import SwiftUI

struct HomeSmallWidget: Widget {
    let kind = "HomeSmall"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CounterSelectionIntent.self,
            provider: UntouchedProvider()
        ) { entry in
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
        VStack(alignment: .leading, spacing: 4) {
            Text(Copy.Widget.brand)
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.4))
            Text("\(entry.counterName).")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.days)")
                    .font(.system(size: 44, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(Copy.Widget.daysSuffix)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
