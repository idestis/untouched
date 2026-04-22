import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreService.shared
    @State private var alertMessage: String?
    @State private var isRestoring: Bool = false

    private var productReady: Bool { store.product != nil }
    private var busy: Bool { store.isPurchasing || isRestoring }

    private var displayPrice: String {
        store.product?.displayPrice ?? Copy.Paywall.price
    }

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
                    Text(displayPrice)
                        .font(.utCoinNumber)
                        .foregroundStyle(Color.utAmber)
                    Text(Copy.Paywall.priceUnit)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                    Spacer()
                    if !productReady {
                        ProgressView()
                            .tint(Color.utTextTertiary)
                    }
                }
            }

            Spacer()

            VStack(spacing: 10) {
                PillButton(
                    title: Copy.Paywall.cta,
                    isEnabled: productReady && !busy
                ) {
                    Task { await purchase() }
                }
                PillButton(
                    title: Copy.Paywall.restore,
                    style: .ghost,
                    isEnabled: !busy
                ) {
                    Task { await restore() }
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
        .alert(
            Copy.Settings.somethingWrong,
            isPresented: alertBinding,
            presenting: alertMessage
        ) { _ in
            Button(Copy.Settings.okButton, role: .cancel) { alertMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }

    @MainActor
    private func purchase() async {
        guard productReady else {
            alertMessage = Copy.Settings.purchaseNothingMessage
            return
        }
        do {
            try await store.purchase()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    @MainActor
    private func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            let outcome = try await store.restore()
            switch outcome {
            case .unlocked:
                break // onChange(isPremiumUnlocked) dismisses
            case .nothingFound:
                alertMessage = Copy.Settings.purchaseNothingMessage
            }
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
