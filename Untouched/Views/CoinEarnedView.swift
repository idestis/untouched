import SwiftUI
import SwiftData

struct CoinEarnedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let coin: EarnedCoin
    @State private var engraving: String = ""
    @State private var stroke: CGFloat = 0
    @State private var showEngravingSheet = false

    private var reduceGlow: Bool { profiles.first?.reduceAmberGlow ?? false }

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            if !reduceGlow {
                RadialGradient(
                    colors: [
                        Color.utCoinAuraInner.opacity(0.70),
                        Color.utCoinAuraMid.opacity(0.55),
                        Color.utCoinAuraOuter.opacity(0.45),
                        Color.utCoinAuraOuter.opacity(0.25)
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 440
                )
                .ignoresSafeArea()
                .opacity(stroke)
            }

            VStack(spacing: 0) {
                Spacer()

                LabelText(text: Copy.CoinEarned.milestoneHeld, color: Color.utAmber)
                    .padding(.bottom, 10)
                    .opacity(stroke)

                Text(titleText)
                    .font(.utScreenTitle)
                    .foregroundStyle(Color.utTextPrimary)
                    .tracking(-1)
                    .multilineTextAlignment(.center)
                    .opacity(stroke)

                Spacer(minLength: 32)

                CoinRing(value: coin.dayValue, earned: true, size: .large)
                    .opacity(stroke)
                    .animation(Motion.utCoinEnter, value: stroke)

                Spacer(minLength: 28)

                engravingRow
                    .opacity(stroke)

                Spacer()

                VStack(spacing: 14) {
                    PillButton(title: Copy.CoinEarned.keep) { keep() }
                    Button(action: share) {
                        Text(Copy.CoinEarned.share)
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .opacity(stroke)
            }
        }
        .onAppear {
            withAnimation(Motion.utCoinEnter) { stroke = 1 }
        }
        .sheet(isPresented: $showEngravingSheet) {
            EngravingSheet(engraving: $engraving)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.utBackground)
        }
    }

    private var engravingRow: some View {
        Button {
            HapticsService.selection()
            showEngravingSheet = true
        } label: {
            VStack(spacing: 6) {
                if engraving.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(Copy.CoinEarned.tapToEngrave)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextTertiary)
                } else {
                    Text("\u{201C}\(engraving)\u{201D}")
                        .font(.utBody.italic())
                        .foregroundStyle(Color.utTextSecondary)
                        .multilineTextAlignment(.center)
                    Text(Copy.CoinEarned.tapToEdit)
                        .font(.utLabel)
                        .tracking(1.5)
                        .foregroundStyle(Color.utTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var titleText: String {
        coin.milestone.map { Copy.Milestones.title(for: $0) } ?? "\(coin.dayValue) days."
    }

    private func keep() {
        let trimmed = engraving.trimmingCharacters(in: .whitespacesAndNewlines)
        coin.engraving = trimmed.isEmpty ? nil : trimmed
        try? modelContext.save()
        if profiles.first?.coinsBackupEnabled == true, let counter = coin.counter {
            CoinBackupService.shared.sync(counter)
        }
        dismiss()
    }

    private func share() {
        // Share card rendering is a v1 TODO. Keep silent for now.
        dismiss()
    }
}

private struct EngravingSheet: View {
    @Binding var engraving: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                LabelText(text: Copy.CoinEarned.engravingPrompt)
                Spacer()
                Button(action: { dismiss() }) {
                    Text(Copy.CoinEarned.doneButton)
                        .font(.utBodyMedium)
                        .foregroundStyle(Color.utAmber)
                }
            }

            TextField(Copy.CoinEarned.engravingPlaceholder, text: $engraving, axis: .vertical)
                .font(.utBody.italic())
                .foregroundStyle(Color.utTextPrimary)
                .lineLimit(3, reservesSpace: true)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.utBorder, lineWidth: 0.5)
                )
                .focused($focused)
                .submitLabel(.done)
                .onSubmit { dismiss() }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { focused = true }
    }
}
