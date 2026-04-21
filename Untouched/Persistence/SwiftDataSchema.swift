import Foundation
import SwiftData

enum UntouchedSchema {
    static let appGroup = "group.app.getuntouched"

    static let models: [any PersistentModel.Type] = [
        Counter.self,
        Reset.self,
        EarnedCoin.self,
        UserProfile.self,
    ]

    @MainActor
    static func makeContainer() -> ModelContainer {
        let schema = Schema(models)
        let config: ModelConfiguration
        if let url = sharedStoreURL() {
            config = ModelConfiguration(schema: schema, url: url)
        } else {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// App-Group URL so the widget extension reads the same store.
    static func sharedStoreURL() -> URL? {
        guard let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else { return nil }
        return container.appendingPathComponent("untouched.store")
    }
}
