import Foundation
import WidgetKit
import SwiftData

struct UntouchedEntry: TimelineEntry {
    let date: Date
    let counterName: String
    let days: Int
    let nextMilestoneDays: Int?
    let lastEarnedDays: Int?
    let daysUntilNextCoin: Int?
    let windowProgress: Double
    /// User-configurable. Lock screen widgets hide the counter's name when
    /// false to keep the typed noun private on a public surface.
    let showName: Bool

    static let placeholder = UntouchedEntry(
        date: Date(),
        counterName: "Untouched",
        days: 47,
        nextMilestoneDays: 60,
        lastEarnedDays: 30,
        daysUntilNextCoin: 13,
        windowProgress: 0.56,
        showName: true
    )
}

struct UntouchedProvider: AppIntentTimelineProvider {
    typealias Entry = UntouchedEntry
    typealias Intent = CounterSelectionIntent

    func placeholder(in context: Context) -> UntouchedEntry { .placeholder }

    func snapshot(for configuration: CounterSelectionIntent, in context: Context) async -> UntouchedEntry {
        loadEntry(for: configuration) ?? .placeholder
    }

    func timeline(
        for configuration: CounterSelectionIntent,
        in context: Context
    ) async -> Timeline<UntouchedEntry> {
        let entry = loadEntry(for: configuration) ?? .placeholder
        let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }

    /// Look up the configured counter, falling back to the oldest active one
    /// so the widget still renders before the user has picked — same behavior
    /// as v1 non-configurable widgets.
    private func loadEntry(for configuration: CounterSelectionIntent) -> UntouchedEntry? {
        guard let container = try? makeSharedContainer() else { return nil }
        let context = ModelContext(container)

        let counter: Counter?
        if let idString = configuration.counter?.id,
           let uuid = UUID(uuidString: idString) {
            let fetch = FetchDescriptor<Counter>(
                predicate: #Predicate<Counter> { $0.id == uuid && !$0.isArchived }
            )
            counter = try? context.fetch(fetch).first
        } else {
            let fetch = FetchDescriptor<Counter>(
                predicate: #Predicate<Counter> { !$0.isArchived },
                sortBy: [SortDescriptor(\Counter.createdDate)]
            )
            counter = try? context.fetch(fetch).first
        }

        guard let counter else { return nil }

        let now = Date()
        let days = CounterEngine.daysUntouched(for: counter)
        let next = CounterEngine.nextMilestone(for: counter, now: now)
        let lastEarned = counter.earnedCoins.sorted(by: { $0.dayValue < $1.dayValue }).last
        let progress = CounterEngine.progressToNextMilestone(for: counter, now: now)

        return UntouchedEntry(
            date: now,
            counterName: counter.name,
            days: days,
            nextMilestoneDays: next?.milestone.dayValue,
            lastEarnedDays: lastEarned?.dayValue,
            daysUntilNextCoin: next?.daysRemaining,
            windowProgress: progress,
            showName: configuration.showName
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
