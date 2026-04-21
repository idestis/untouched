import SwiftUI
import SwiftData

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var showCrisis = false
    @State private var isRestoring = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(Copy.Settings.notificationsToggle, isOn: Binding(
                        get: { profile?.notificationsEnabled ?? false },
                        set: { profile?.notificationsEnabled = $0 }
                    ))
                    if profile?.notificationsEnabled ?? false {
                        DatePicker(
                            Copy.Settings.notificationTimeLabel,
                            selection: Binding(
                                get: {
                                    if let c = profile?.dailyCheckInTime,
                                       let h = c.hour, let m = c.minute,
                                       let date = Calendar.current.date(from: DateComponents(hour: h, minute: m)) {
                                        return date
                                    }
                                    return Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
                                },
                                set: { newDate in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    profile?.setDailyCheckInTime(comps)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section {
                    Toggle(Copy.Settings.hapticsToggle, isOn: Binding(
                        get: { profile?.hapticsEnabled ?? true },
                        set: {
                            profile?.hapticsEnabled = $0
                            HapticsService.enabled = $0
                        }
                    ))
                    Toggle(Copy.Settings.reduceGlowToggle, isOn: Binding(
                        get: { profile?.reduceAmberGlow ?? false },
                        set: { profile?.reduceAmberGlow = $0 }
                    ))
                }

                Section {
                    Button(Copy.Settings.restorePurchase) {
                        Task {
                            isRestoring = true
                            defer { isRestoring = false }
                            try? await StoreService.shared.restore()
                        }
                    }
                    .disabled(isRestoring)

                    Button(Copy.Settings.crisisResources) { showCrisis = true }
                        .foregroundStyle(Color.utTextSecondary)
                }

                Section {
                    HStack {
                        Text(Copy.Settings.version)
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(Color.utTextSecondary)
                    }
                }
            }
            .navigationTitle(Copy.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showCrisis) { CrisisResourcesView() }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v) (\(b))"
    }
}
