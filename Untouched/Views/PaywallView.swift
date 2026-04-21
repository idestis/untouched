import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreService.shared
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 16)

            Text(Copy.Paywall.title)
                .font(.utScreenTitle)
                .tracking(-1)
                .foregroundStyle(Color.utTextPrimary)

            Text(Copy.Paywall.body)
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            BentoCard(padding: 20) {
                HStack(alignment: .firstTextBaseline) {
                    Text(Copy.Paywall.price)
                        .font(.utCoinNumber)
                        .foregroundStyle(Color.utAmber)
                    Text(Copy.Paywall.priceUnit)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                    Spacer()
                }
            }

            Spacer()

            VStack(spacing: 10) {
                PillButton(title: Copy.Paywall.cta) {
                    Task { await purchase() }
                }
                PillButton(title: Copy.Paywall.restore, style: .ghost) {
                    Task { try? await store.restore() }
                }
            }

            Text(Copy.Paywall.footer)
                .font(.utLabel)
                .tracking(1.5)
                .foregroundStyle(Color.utTextTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .background(Color.utBackground.ignoresSafeArea())
        .task { await store.start() }
        .onChange(of: store.isPremiumUnlocked) { _, unlocked in
            if unlocked { dismiss() }
        }
    }

    @MainActor
    private func purchase() async {
        do {
            try await store.purchase()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
