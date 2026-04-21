import WidgetKit

/// Thin wrapper around WidgetCenter so callers don't depend on WidgetKit directly.
/// Call whenever counter state changes: reset, coin earned, add/remove counter,
/// daily check-in time changed.
enum WidgetTimelineService {
    static func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func reload(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}
