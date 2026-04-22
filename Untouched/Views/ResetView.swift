import SwiftUI
import SwiftData

struct ResetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let counter: Counter
    @State private var confession: String = ""
    @FocusState private var editorFocused: Bool

    private let minChars = 5
    private let maxChars = 280

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        LabelText(text: Copy.Reset.label, color: Color.utDanger)
                        Text(Copy.Reset.title)
                            .font(.utScreenTitle)
                            .tracking(-1)
                            .foregroundStyle(Color.utTextPrimary)
                        Text(Copy.Reset.body)
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    inputCard
                    calloutCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }

            VStack(spacing: 14) {
                PillButton(title: Copy.Reset.confirm, style: .danger, isEnabled: isValid) {
                    commitReset()
                }
                Button(action: { dismiss() }) {
                    Text(Copy.Reset.cancel)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .background(Color.utBackground.ignoresSafeArea())
        .onAppear { editorFocused = true }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(Copy.Reset.placeholder, text: $confession, axis: .vertical)
                .font(.utBody)
                .foregroundStyle(Color.utTextPrimary)
                .lineLimit(3, reservesSpace: true)
                .focused($editorFocused)
                .onChange(of: confession) { _, new in
                    if new.count > maxChars {
                        confession = String(new.prefix(maxChars))
                    }
                }
            LabelText(text: Copy.Reset.characters(confession.count))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.utSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.utBorder, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var calloutCard: some View {
        let days = CounterEngine.daysUntouched(for: counter)
        let coins = counter.earnedCoins.count
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.utAmber)
                .padding(.top, 2)
            Text(Copy.Reset.confirmCallout(days: days, coins: coins))
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.utAmber.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.utAmber.opacity(0.45), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var isValid: Bool {
        confession.trimmingCharacters(in: .whitespacesAndNewlines).count >= minChars
    }

    private func commitReset() {
        guard isValid else { return }
        let runDays = CounterEngine.daysUntouched(for: counter)
        let sealed: Data
        do {
            sealed = try CryptoService.seal(confession)
        } catch {
            return
        }
        let reset = Reset(date: Date(), confessionSealed: sealed, runLengthDays: runDays)
        counter.resets.append(reset)
        modelContext.insert(reset)
        reset.counter = counter
        counter.allTimeLongest = max(counter.allTimeLongest, runDays)
        counter.startDate = Date()

        HapticsService.heavy()
        WidgetTimelineService.reloadAll()
        NotificationService.scheduleMilestones(for: counter)
        if profiles.first?.coinsBackupEnabled == true {
            CoinBackupService.shared.sync(counter)
        }
        dismiss()
    }
}
