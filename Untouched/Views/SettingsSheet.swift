import SwiftUI
import SwiftData

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(filter: #Predicate<Counter> { !$0.isArchived }, sort: \Counter.createdDate)
    private var activeCounters: [Counter]

    @AppStorage("appearanceMode") private var appearanceModeRaw: Int = AppearanceMode.dark.rawValue

    @State private var showTimePicker = false
    @State private var showBackupConsent = false
    @State private var showBackupUnavailable = false

    @State private var isRestoringPurchase = false
    @State private var purchaseOutcome: StoreService.RestoreOutcome? = nil
    @State private var purchaseError: String? = nil

    @State private var isRestoringCoins = false
    @State private var coinsRestoredCount: Int? = nil
    @State private var showCoinsEmpty = false
    @State private var coinsRestoreError: String? = nil

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 22)
                    .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        checkInRow
                        if profile?.notificationsEnabled ?? false {
                            divider
                            reminderTimeRow
                        }
                        divider
                        hapticsRow
                        divider
                        reduceGlowRow
                        divider
                        appearanceRow
                        divider
                        backupRow
                        divider
                        restoreCoinsRow
                        divider
                        restorePurchaseRow
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                    Text(appVersion)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.utTextTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 36)
                        .padding(.bottom, 24)
                }
            }
        }
        .presentationBackground(Color.utBackground)
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showTimePicker) { timePickerSheet }
        .alert(Copy.Settings.backupConsentTitle, isPresented: $showBackupConsent) {
            Button(Copy.Settings.backupConsentCancel, role: .cancel) {}
            Button(Copy.Settings.backupConsentConfirm) { enableBackup() }
        } message: {
            Text(Copy.Settings.backupConsentMessage)
        }
        .alert(Copy.Settings.backupUnavailableTitle, isPresented: $showBackupUnavailable) {
            Button(Copy.Settings.okButton, role: .cancel) {}
        } message: {
            Text(Copy.Settings.backupUnavailableMessage)
        }
        .alert(purchaseAlertTitle, isPresented: purchaseOutcomeBinding) {
            Button(Copy.Settings.okButton) { purchaseOutcome = nil }
        } message: {
            Text(purchaseAlertMessage)
        }
        .alert(Copy.Settings.somethingWrong, isPresented: purchaseErrorBinding) {
            Button(Copy.Settings.okButton, role: .cancel) { purchaseError = nil }
        } message: {
            Text(purchaseError ?? "")
        }
        .alert(Copy.Settings.restoreCoinsRestoredTitle, isPresented: coinsRestoredBinding) {
            Button(Copy.Settings.okButton) { coinsRestoredCount = nil }
        } message: {
            Text(Copy.Settings.restoreCoinsRestoredMessage(coinsRestoredCount ?? 0))
        }
        .alert(Copy.Settings.restoreCoinsEmptyTitle, isPresented: $showCoinsEmpty) {
            Button(Copy.Settings.okButton, role: .cancel) {}
        } message: {
            Text(Copy.Settings.restoreCoinsEmptyMessage)
        }
        .alert(Copy.Settings.somethingWrong, isPresented: coinsRestoreErrorBinding) {
            Button(Copy.Settings.okButton, role: .cancel) { coinsRestoreError = nil }
        } message: {
            Text(coinsRestoreError ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Copy.Settings.title)
                    .font(.system(size: 28, weight: .medium))
                    .tracking(-0.8)
                    .foregroundStyle(Color.utTextPrimary)
                Text(Copy.Settings.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.utTextSecondary)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.utTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.utSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Rows

    private var checkInRow: some View {
        toggleRow(
            title: Copy.Settings.notificationsTitle,
            subtitle: Copy.Settings.notificationsSubtitle,
            value: Binding(
                get: { profile?.notificationsEnabled ?? false },
                set: { new in
                    profile?.notificationsEnabled = new
                    handleNotificationsChange(new)
                }
            )
        )
    }

    private var reminderTimeRow: some View {
        row(
            title: Copy.Settings.reminderTitle,
            subtitle: Copy.Settings.reminderSubtitle,
            trailing: {
                AnyView(
                    HStack(spacing: 4) {
                        Text(reminderString)
                            .font(.utBodyMedium)
                            .foregroundStyle(Color.utTextPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.utTextTertiary)
                    }
                )
            },
            action: { showTimePicker = true }
        )
    }

    private var hapticsRow: some View {
        toggleRow(
            title: Copy.Settings.hapticsTitle,
            subtitle: Copy.Settings.hapticsSubtitle,
            value: Binding(
                get: { profile?.hapticsEnabled ?? true },
                set: { new in
                    profile?.hapticsEnabled = new
                    HapticsService.enabled = new
                }
            )
        )
    }

    private var reduceGlowRow: some View {
        toggleRow(
            title: Copy.Settings.reduceGlowTitle,
            subtitle: Copy.Settings.reduceGlowSubtitle,
            value: Binding(
                get: { profile?.reduceAmberGlow ?? false },
                set: { profile?.reduceAmberGlow = $0 }
            )
        )
    }

    private var appearanceRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.Settings.appearanceTitle)
                    .font(.utBodyMedium)
                    .foregroundStyle(Color.utTextPrimary)
                Text(Copy.Settings.appearanceSubtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.utTextTertiary)
            }
            HStack(spacing: 6) {
                ForEach(AppearanceMode.allCases) { mode in
                    appearanceCell(mode)
                }
            }
        }
        .padding(.vertical, 14)
    }

    private func appearanceCell(_ mode: AppearanceMode) -> some View {
        let selected = appearanceModeRaw == mode.rawValue
        return Button {
            HapticsService.selection()
            appearanceModeRaw = mode.rawValue
            AppearanceMode.apply(mode.rawValue)
        } label: {
            Text(mode.label)
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(selected ? Color.utBackground : Color.utTextSecondary)
                .background(selected ? Color.utTextPrimary : Color.utSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.utBorder, lineWidth: selected ? 0 : 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var backupRow: some View {
        toggleRow(
            title: Copy.Settings.backupTitle,
            subtitle: Copy.Settings.backupSubtitle,
            value: Binding(
                get: { profile?.coinsBackupEnabled ?? false },
                set: { requested in
                    handleBackupToggle(requested)
                }
            )
        )
    }

    private var restoreCoinsRow: some View {
        linkRow(
            title: Copy.Settings.restoreCoinsTitle,
            subtitle: Copy.Settings.restoreCoinsSubtitle,
            disabled: isRestoringCoins
        ) {
            restoreCoins()
        }
    }

    private var restorePurchaseRow: some View {
        linkRow(
            title: Copy.Settings.restorePurchase,
            subtitle: Copy.Settings.restorePurchaseSubtitle,
            disabled: isRestoringPurchase
        ) {
            Task { await restorePurchase() }
        }
    }

    // MARK: - Row primitives

    private var divider: some View {
        Rectangle()
            .fill(Color.utBorder)
            .frame(height: 0.5)
    }

    private func row(
        title: String,
        subtitle: String,
        trailing: () -> AnyView,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticsService.selection()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.utBodyMedium)
                        .foregroundStyle(Color.utTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.utTextTertiary)
                }
                Spacer()
                trailing()
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        value: Binding<Bool>
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.utBodyMedium)
                    .foregroundStyle(Color.utTextPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.utTextTertiary)
            }
            Spacer()
            Toggle("", isOn: value)
                .labelsHidden()
                .tint(Color.utAmber)
        }
        .padding(.vertical, 12)
    }

    private func linkRow(
        title: String,
        subtitle: String?,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticsService.selection()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.utBodyMedium)
                        .foregroundStyle(Color.utTextPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.utTextTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.utTextTertiary)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }

    // MARK: - Time picker sheet

    private var timePickerSheet: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(Copy.Settings.reminderTitle)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.utTextPrimary)
                    .padding(.top, 24)

                DatePicker(
                    "",
                    selection: Binding(
                        get: { currentReminderDate },
                        set: { newDate in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            profile?.setDailyCheckInTime(comps)
                            if profile?.notificationsEnabled == true {
                                for counter in activeCounters {
                                    NotificationService.scheduleMilestones(for: counter, at: comps)
                                }
                            }
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(Color.utAmber)

                PillButton(title: Copy.CoinEarned.doneButton) {
                    showTimePicker = false
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
            }
        }
        .presentationDetents([.height(340)])
        .presentationBackground(Color.utBackground)
    }

    // MARK: - Derived

    private var currentReminderDate: Date {
        if let c = profile?.dailyCheckInTime,
           let h = c.hour, let m = c.minute,
           let date = Calendar.current.date(from: DateComponents(hour: h, minute: m)) {
            return date
        }
        return Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }

    private var reminderString: String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: currentReminderDate)
    }

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "v\(v) (\(b))"
    }

    // MARK: - Actions

    private func handleNotificationsChange(_ enabled: Bool) {
        if enabled {
            let counters = activeCounters
            let time = profile?.dailyCheckInTime ?? NotificationService.defaultMilestoneTime
            Task {
                let granted = await NotificationService.requestAuthorization()
                await MainActor.run {
                    if granted {
                        for counter in counters {
                            NotificationService.scheduleMilestones(for: counter, at: time)
                        }
                    } else {
                        profile?.notificationsEnabled = false
                    }
                }
            }
        } else {
            NotificationService.removeAllPending()
        }
    }

    private func handleBackupToggle(_ requested: Bool) {
        guard let profile else { return }
        if requested {
            guard CoinBackupService.shared.isAccountAvailable else {
                showBackupUnavailable = true
                return
            }
            showBackupConsent = true
        } else {
            profile.coinsBackupEnabled = false
        }
    }

    private func enableBackup() {
        guard let profile else { return }
        profile.coinsBackupEnabled = true
        CoinBackupService.shared.syncAll(activeCounters)
    }

    private func restoreCoins() {
        guard !isRestoringCoins else { return }
        isRestoringCoins = true
        defer { isRestoringCoins = false }

        if !CoinBackupService.shared.isAccountAvailable {
            showBackupUnavailable = true
            return
        }

        let count = CoinBackupService.shared.restoreAll(
            into: modelContext,
            counters: activeCounters
        )
        if count > 0 {
            HapticsService.success()
            WidgetTimelineService.reloadAll()
            coinsRestoredCount = count
        } else {
            showCoinsEmpty = true
        }
    }

    @MainActor
    private func restorePurchase() async {
        guard !isRestoringPurchase else { return }
        isRestoringPurchase = true
        defer { isRestoringPurchase = false }
        do {
            let outcome = try await StoreService.shared.restore()
            purchaseOutcome = outcome
            if outcome == .unlocked { HapticsService.success() }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Alert bindings

    private var purchaseOutcomeBinding: Binding<Bool> {
        Binding(
            get: { purchaseOutcome != nil },
            set: { if !$0 { purchaseOutcome = nil } }
        )
    }

    private var purchaseErrorBinding: Binding<Bool> {
        Binding(
            get: { purchaseError != nil },
            set: { if !$0 { purchaseError = nil } }
        )
    }

    private var coinsRestoredBinding: Binding<Bool> {
        Binding(
            get: { coinsRestoredCount != nil },
            set: { if !$0 { coinsRestoredCount = nil } }
        )
    }

    private var coinsRestoreErrorBinding: Binding<Bool> {
        Binding(
            get: { coinsRestoreError != nil },
            set: { if !$0 { coinsRestoreError = nil } }
        )
    }

    private var purchaseAlertTitle: String {
        purchaseOutcome == .unlocked
            ? Copy.Settings.purchaseRestoredTitle
            : Copy.Settings.purchaseNothingTitle
    }

    private var purchaseAlertMessage: String {
        purchaseOutcome == .unlocked
            ? Copy.Settings.purchaseRestoredMessage
            : Copy.Settings.purchaseNothingMessage
    }
}
