import SwiftUI
import SwiftData

struct CoinEarnedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let coin: EarnedCoin
    @State private var engraving: String = ""
    @State private var stroke: CGFloat = 0

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            RadialGradient(
                colors: [Color.utAmberSoft, .clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .opacity(stroke)

            VStack(spacing: 0) {
                Spacer()

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

                Spacer(minLength: 32)

                VStack(alignment: .leading, spacing: 8) {
                    LabelText(text: Copy.CoinEarned.engravingPrompt)
                    TextField(Copy.CoinEarned.engravingPlaceholder, text: $engraving)
                        .font(.utBody.italic())
                        .foregroundStyle(Color.utTextSecondary)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.utBorder, lineWidth: 0.5)
                        )
                }
                .padding(.horizontal, 22)
                .opacity(stroke)

                Spacer()

                VStack(spacing: 10) {
                    PillButton(title: Copy.CoinEarned.keep) { keep() }
                    PillButton(title: Copy.CoinEarned.share, style: .ghost) { share() }
                }
                .padding(.horizontal, 22)
                .opacity(stroke)
            }
        }
        .onAppear {
            withAnimation(Motion.utCoinEnter) { stroke = 1 }
        }
    }

    private var titleText: String {
        coin.milestone.map { Copy.Milestones.title(for: $0) } ?? "\(coin.dayValue) days."
    }

    private func keep() {
        let trimmed = engraving.trimmingCharacters(in: .whitespacesAndNewlines)
        coin.engraving = trimmed.isEmpty ? nil : trimmed
        try? modelContext.save()
        dismiss()
    }

    private func share() {
        // Share card rendering is a v1 TODO. Keep silent for now.
        dismiss()
    }
}
