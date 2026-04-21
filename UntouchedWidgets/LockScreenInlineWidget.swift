import WidgetKit
import SwiftUI

struct LockScreenInlineWidget: Widget {
    let kind = "LockScreenInline"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UntouchedProvider()) { entry in
            Text("\(entry.days) days untouched")
        }
        .configurationDisplayName("Days Untouched")
        .description("A single number on your lock screen.")
        .supportedFamilies([.accessoryInline])
    }
}
