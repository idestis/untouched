import WidgetKit
import SwiftUI

struct LockScreenRectangularWidget: Widget {
    let kind = "LockScreenRectangular"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UntouchedProvider()) { entry in
            VStack(alignment: .leading, spacing: 2) {
                Text("UNTOUCHED")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2)
                    .widgetAccentable()
                Text("\(entry.days)")
                    .font(.system(size: 28, weight: .medium))
                    .monospacedDigit()
                if let next = entry.nextMilestoneDays {
                    Text("\(next - entry.days) days until next coin")
                        .font(.system(size: 10))
                }
            }
        }
        .configurationDisplayName("Days + Next Coin")
        .description("Days untouched and time until the next milestone.")
        .supportedFamilies([.accessoryRectangular])
    }
}
