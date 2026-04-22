import AppIntents
import SwiftData
import WidgetKit

/// Entity representing a counter the user can pick in the widget editor.
/// Stable id = the counter's UUID, so the chosen counter survives rename.
struct CounterEntity: AppEntity {
    let id: String
    let name: String

    static let typeDisplayRepresentation: TypeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Counter")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static let defaultQuery = CounterQuery()
}

struct CounterQuery: EntityQuery {
    func entities(for identifiers: [CounterEntity.ID]) async throws -> [CounterEntity] {
        loadCounters().filter { identifiers.contains($0.id) }
    }

    /// Populates the counter picker when the user edits the widget.
    func suggestedEntities() async throws -> [CounterEntity] {
        loadCounters()
    }

    /// Default selection when the widget is first dropped on the home/lock
    /// screen. The first active counter keeps the v1 behavior for users
    /// upgrading from the non-configurable version.
    func defaultResult() async -> CounterEntity? {
        loadCounters().first
    }

    private func loadCounters() -> [CounterEntity] {
        guard let container = try? makeSharedContainer() else { return [] }
        let context = ModelContext(container)
        let fetch = FetchDescriptor<Counter>(
            predicate: #Predicate<Counter> { !$0.isArchived },
            sortBy: [SortDescriptor(\Counter.createdDate)]
        )
        guard let counters = try? context.fetch(fetch) else { return [] }
        return counters.map { CounterEntity(id: $0.id.uuidString, name: $0.name) }
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

struct CounterSelectionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Counter"
    static let description = IntentDescription(
        "Pick which counter this widget shows."
    )

    @Parameter(title: "Counter")
    var counter: CounterEntity?

    /// Controls whether the counter's name is visible on this widget. Off on
    /// lock screen surfaces by default so the word the user typed isn't
    /// visible to anyone glancing at the phone.
    @Parameter(
        title: "Show name",
        description: "Off hides the counter's name. Useful on the lock screen.",
        default: true
    )
    var showName: Bool

    init() {}

    init(counter: CounterEntity?, showName: Bool = true) {
        self.counter = counter
        self.showName = showName
    }
}
