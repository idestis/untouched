import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var profiles: [UserProfile]

    @AppStorage("appearanceMode") private var appearanceModeRaw: Int = AppearanceMode.dark.rawValue

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
        .onAppear { AppearanceMode.apply(appearanceModeRaw) }
        .onChange(of: appearanceModeRaw) { _, raw in
            AppearanceMode.apply(raw)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { AppearanceMode.apply(appearanceModeRaw) }
        }
    }

    @MainActor
    private func ensureProfile() {
        if profiles.isEmpty {
            modelContext.insert(UserProfile())
        }
    }
}
