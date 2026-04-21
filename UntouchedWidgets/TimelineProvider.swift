import Foundation
import WidgetKit
import SwiftData

struct UntouchedEntry: TimelineEntry {
    let date: Date
    let counterName: String
    let days: Int
    let nextMilestoneDays: Int?
    let lastEarnedDays: Int?

    static let placeholder = UntouchedEntry(
        date: Date(),
        counterName: "Untouched",
        days: 47,
        nextMilestoneDays: 60,
        lastEarnedDays: 30
    )
}

struct UntouchedProvider: TimelineProvider {
    func placeholder(in context: Context) -> UntouchedEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (UntouchedEntry) -> Void) {
        completion(loadEntry() ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UntouchedEntry>) -> Void) {
        let now = Date()
        let entry = loadEntry() ?? .placeholder
        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)

        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    /// Read the shared SwiftData store. Returns `nil` if no active counter.
    private func loadEntry() -> UntouchedEntry? {
        guard let container = try? makeSharedContainer() else { return nil }
        let context = ModelContext(container)

        let fetch = FetchDescriptor<Counter>(
            predicate: #Predicate<Counter> { !$0.isArchived },
            sortBy: [SortDescriptor(\Counter.createdDate)]
        )
        guard let counter = try? context.fetch(fetch).first else { return nil }

        let days = CounterEngine.daysUntouched(for: counter)
        let next = CounterEngine.nextMilestone(for: counter)
        let lastEarned = counter.earnedCoins.sorted(by: { $0.dayValue < $1.dayValue }).last

        return UntouchedEntry(
            date: Date(),
            counterName: counter.name,
            days: days,
            nextMilestoneDays: next?.0.dayValue,
            lastEarnedDays: lastEarned?.dayValue
        )
    }

    private func makeSharedContainer() throws -> ModelContainer {
        let schema = Schema(UntouchedSchema.models)
        let config: ModelConfiguration
        if let url = UntouchedSchema.sharedStoreURL() {
            config = ModelConfiguration(schema: schema, url: url)
        } else {
            config = ModelConfiguration(schema: schema)
        }
        return try ModelContainer(for: schema, configurations: [config])
    }
}
