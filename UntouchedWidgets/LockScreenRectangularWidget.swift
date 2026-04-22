import WidgetKit
import SwiftUI

struct LockScreenRectangularWidget: Widget {
    let kind = "LockScreenRectangular"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CounterSelectionIntent.self,
            provider: UntouchedProvider()
        ) { entry in
            LockScreenRectangularView(entry: entry)
        }
        .configurationDisplayName("Days + Next Coin")
        .description("Days untouched and time until the next milestone.")
        .supportedFamilies([.accessoryRectangular])
    }
}

private struct LockScreenRectangularView: View {
    let entry: UntouchedEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.showName ? entry.counterName.uppercased() : Copy.Today.daysLabel)
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .widgetAccentable()
                .lineLimit(1)
            Text("\(entry.days)")
                .font(.system(size: 28, weight: .medium))
                .monospacedDigit()
            if let remaining = entry.daysUntilNextCoin {
                Text(Copy.Widget.daysUntilNextCoin(remaining))
                    .font(.system(size: 10))
            }
        }
    }
}
