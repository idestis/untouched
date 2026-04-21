import SwiftUI
import SwiftData

struct ResetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let counter: Counter
    @State private var confession: String = ""

    private let minChars = 5
    private let maxChars = 280

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer(minLength: 16)

            Text(Copy.Reset.title)
                .font(.utScreenTitle)
                .tracking(-1)
                .foregroundStyle(Color.utTextPrimary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $confession)
                    .font(.utBody)
                    .foregroundStyle(Color.utTextPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(12)

                if confession.isEmpty {
                    Text(Copy.Reset.placeholder)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextTertiary)
                        .padding(18)
                        .allowsHitTesting(false)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.utBorder, lineWidth: 0.5)
            )
            .onChange(of: confession) { _, new in
                if new.count > maxChars {
                    confession = String(new.prefix(maxChars))
                }
            }

            HStack {
                Text("\(confession.count) / \(maxChars)")
                    .font(.utLabel)
                    .foregroundStyle(Color.utTextTertiary)
                Spacer()
                if confession.count < minChars {
                    Text(Copy.Reset.minCharsHint)
                        .font(.utLabel)
                        .foregroundStyle(Color.utTextTertiary)
                }
            }

            BentoCard(padding: 16) {
                let days = CounterEngine.daysUntouched(for: counter)
                let coins = counter.earnedCoins.count
                Text(Copy.Reset.confirmCallout(days: days, coins: coins))
                    .font(.utBody)
                    .foregroundStyle(Color.utAmber)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(spacing: 10) {
                PillButton(title: Copy.Reset.confirm, style: .danger, isEnabled: isValid) {
                    commitReset()
                }
                PillButton(title: Copy.Reset.cancel, style: .ghost) { dismiss() }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .background(Color.utBackground.ignoresSafeArea())
    }

    private var isValid: Bool { confession.trimmingCharacters(in: .whitespacesAndNewlines).count >= minChars }

    private func commitReset() {
        guard isValid else { return }
        let runDays = CounterEngine.daysUntouched(for: counter)
        let sealed: Data
        do {
            sealed = try CryptoService.seal(confession)
        } catch {
            // If encryption fails, surface nothing and bail — never write plaintext.
            return
        }
        let reset = Reset(date: Date(), confessionSealed: sealed, runLengthDays: runDays)
        counter.resets.append(reset)
        modelContext.insert(reset)
        reset.counter = counter
        counter.allTimeLongest = max(counter.allTimeLongest, runDays)
        counter.startDate = Date()
        // Note: counter.earnedCoins is NOT cleared. SPEC §12 invariant.

        HapticsService.heavy()
        WidgetTimelineService.reloadAll()
        dismiss()
    }
}
