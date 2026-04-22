import WidgetKit
import SwiftUI

struct LockScreenInlineWidget: Widget {
    let kind = "LockScreenInline"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CounterSelectionIntent.self,
            provider: UntouchedProvider()
        ) { entry in
            Text(
                entry.showName
                    ? Copy.Widget.daysUntouchedNamed(entry.days, name: entry.counterName)
                    : Copy.Widget.daysUntouched(entry.days)
            )
        }
        .configurationDisplayName("Days Untouched")
        .description("A single line on your lock screen.")
        .supportedFamilies([.accessoryInline])
    }
}
