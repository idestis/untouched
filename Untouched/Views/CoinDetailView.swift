import SwiftUI
import SwiftData

struct CoinDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let coin: EarnedCoin
    @State private var showEngravingSheet = false

    private var reduceGlow: Bool { profiles.first?.reduceAmberGlow ?? false }

    var body: some View {
        ZStack(alignment: .top) {
            Color.utBackground.ignoresSafeArea()

            if !reduceGlow {
                RadialGradient(
                    colors: [
                        Color.utCoinAuraInner.opacity(0.55),
                        Color.utCoinAuraMid.opacity(0.42),
                        Color.utCoinAuraOuter.opacity(0.35),
                        Color.utCoinAuraOuter.opacity(0.18)
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 420
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                DragHandle()

                VStack(spacing: 0) {
                    Spacer()

                    LabelText(text: Copy.CoinEarned.milestoneHeld, color: Color.utAmber)
                        .padding(.bottom, 10)

                    Text(titleText)
                        .font(.utScreenTitle)
                        .foregroundStyle(Color.utTextPrimary)
                        .tracking(-1)
                        .multilineTextAlignment(.center)

                    Spacer(minLength: 32)

                    CoinRing(value: coin.dayValue, earned: true, size: .large, glow: false)

                    Spacer(minLength: 28)

                    engravingRow

                    Text("\(Copy.Shelf.earnedOn) \(earnedFormatted)")
                        .font(.utLabel)
                        .tracking(1.5)
                        .foregroundStyle(Color.utTextTertiary)
                        .padding(.top, 20)

                    Spacer()
                }
                .padding(.horizontal, 22)
            }
        }
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showEngravingSheet) {
            EngravingEditorSheet(
                initial: coin.engraving ?? "",
                onCommit: commit
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.utBackground)
        }
    }

    @ViewBuilder
    private var engravingRow: some View {
        let persisted = (coin.engraving ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if persisted.isEmpty {
            Button {
                HapticsService.selection()
                showEngravingSheet = true
            } label: {
                Text(Copy.CoinEarned.tapToEngrave)
                    .font(.utBody)
                    .foregroundStyle(Color.utTextTertiary)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            Button {
                HapticsService.selection()
                showEngravingSheet = true
            } label: {
                VStack(spacing: 4) {
                    Text("\u{201C}\(persisted)\u{201D}")
                        .font(.utBody.italic())
                        .foregroundStyle(Color.utTextSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Text(Copy.CoinEarned.tapToEdit)
                        .font(.utLabel)
                        .tracking(1.5)
                        .foregroundStyle(Color.utTextTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var titleText: String {
        coin.milestone.map { Copy.Milestones.title(for: $0) } ?? "\(coin.dayValue) days."
    }

    private var earnedFormatted: String {
        coin.earnedDate.formatted(.dateTime.month(.abbreviated).day().year())
    }

    private func commit(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        coin.engraving = trimmed.isEmpty ? nil : trimmed
        try? modelContext.save()
        if profiles.first?.coinsBackupEnabled == true, let counter = coin.counter {
            CoinBackupService.shared.sync(counter)
        }
    }
}

struct EngravingEditorSheet: View {
    let initial: String
    let onCommit: (String) -> Void

    @State private var text: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                LabelText(text: Copy.CoinEarned.engravingPrompt)
                Spacer()
                Button {
                    onCommit(text)
                    dismiss()
                } label: {
                    Text(Copy.CoinEarned.doneButton)
                        .font(.utBodyMedium)
                        .foregroundStyle(Color.utAmber)
                }
            }

            TextField(Copy.CoinEarned.engravingPlaceholder, text: $text, axis: .vertical)
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
                .onSubmit {
                    onCommit(text)
                    dismiss()
                }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            text = initial
            focused = true
        }
    }
}
