import SwiftUI
import SwiftData

struct CoinDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let coin: EarnedCoin

    private var reduceGlow: Bool { profiles.first?.reduceAmberGlow ?? false }

    var body: some View {
        ZStack(alignment: .top) {
            Color.utBackground.ignoresSafeArea()

            if !reduceGlow {
                CoinAura(intensity: .soft)
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
    }

    @ViewBuilder
    private var engravingRow: some View {
        let persisted = (coin.engraving ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !persisted.isEmpty {
            Text("\u{201C}\(persisted)\u{201D}")
                .font(.utBody.italic())
                .foregroundStyle(Color.utTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var titleText: String {
        coin.milestone.map { Copy.Milestones.title(for: $0) } ?? "\(coin.dayValue) days."
    }

    private var earnedFormatted: String {
        coin.earnedDate.formatted(.dateTime.month(.abbreviated).day().year())
    }
}
