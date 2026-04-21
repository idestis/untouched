import SwiftUI
import SwiftData

struct PreviousRunsView: View {
    @Environment(\.dismiss) private var dismiss
    let counter: Counter

    var body: some View {
        VStack(spacing: 0) {
            DragHandle()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    LabelText(text: Copy.Shelf.previousRunsLabel)

                    if counter.resets.isEmpty {
                        Text(Copy.Shelf.previousRunsEmpty)
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(counter.resets.sorted(by: { $0.date > $1.date }), id: \.id) { reset in
                                resetCard(reset)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 22)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.utBackground.ignoresSafeArea())
        .presentationDragIndicator(.hidden)
    }

    private func resetCard(_ reset: Reset) -> some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(reset.runLengthDays)")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.utTextPrimary)
                            .monospacedDigit()
                        Text(Copy.Today.daysSuffix)
                            .font(.utBody)
                            .foregroundStyle(Color.utTextTertiary)
                    }
                    Spacer()
                    Text(reset.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.utLabel)
                        .tracking(1.5)
                        .foregroundStyle(Color.utTextTertiary)
                }

                if let text = decrypted(reset.confessionSealed), !text.isEmpty {
                    Text("\u{201C}\(text)\u{201D}")
                        .font(.utBody.italic())
                        .foregroundStyle(Color.utTextSecondary)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func decrypted(_ data: Data) -> String? {
        try? CryptoService.open(data)
    }
}
