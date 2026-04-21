import SwiftUI
import SwiftData

@main
struct UntouchedApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    await StoreService.shared.start()
                }
        }
        .modelContainer(UntouchedSchema.makeContainer())
    }
}
