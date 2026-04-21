import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if profiles.first?.hasCompletedOnboarding == true {
                TodayView()
                    .transition(.utScreen)
            } else {
                ManifestoView()
                    .transition(.utScreen)
            }
        }
        .task { ensureProfile() }
    }

    @MainActor
    private func ensureProfile() {
        if profiles.isEmpty {
            modelContext.insert(UserProfile())
        }
    }
}
