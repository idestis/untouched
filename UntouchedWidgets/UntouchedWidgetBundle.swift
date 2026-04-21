import WidgetKit
import SwiftUI

@main
struct UntouchedWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockScreenInlineWidget()
        LockScreenRectangularWidget()
        HomeSmallWidget()
        HomeMediumWidget()
    }
}
