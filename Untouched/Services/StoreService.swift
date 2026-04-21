import Foundation
import StoreKit

@Observable
@MainActor
final class StoreService {
    static let productID = "com.getuntouched.lifetime"

    static let shared = StoreService()

    enum RestoreOutcome {
        case unlocked
        case nothingFound
    }

    private(set) var product: Product?
    private(set) var isPremiumUnlocked: Bool = false
    private(set) var isPurchasing: Bool = false

    private var updatesTask: Task<Void, Never>?

    func start() async {
        await loadProduct()
        await refreshEntitlement()
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            self.product = products.first
        } catch {
            self.product = nil
        }
    }

    func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Self.productID, t.revocationDate == nil {
                isPremiumUnlocked = true
                return
            }
        }
        isPremiumUnlocked = false
    }

    func purchase() async throws {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            await handle(verification)
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    @discardableResult
    func restore() async throws -> RestoreOutcome {
        try await AppStore.sync()
        await refreshEntitlement()
        return isPremiumUnlocked ? .unlocked : .nothingFound
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let t) = result else { return }
        if t.productID == Self.productID, t.revocationDate == nil {
            isPremiumUnlocked = true
        }
        await t.finish()
    }
}
