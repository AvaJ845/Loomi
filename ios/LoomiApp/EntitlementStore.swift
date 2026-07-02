//
//  EntitlementStore.swift
//  StoreKit 2 purchase + entitlement state for Loomi+. On-device only — no
//  server, no account, consistent with the no-tracking privacy stance.
//

import StoreKit

enum LoomiPlusProduct: String, CaseIterable {
    case lifetime = "loomi.plus.lifetime"
    case annual   = "loomi.plus.annual"
    case monthly  = "loomi.plus.monthly"
}

enum PurchaseOutcome {
    case success
    case cancelled
    case pending
    case failed(String)
}

@MainActor
final class EntitlementStore: ObservableObject {
    static let shared = EntitlementStore()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPlus = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in await self?.listenForTransactions() }
        Task { [weak self] in
            await self?.loadProducts()
            await self?.refreshEntitlement()
        }
    }

    func loadProducts() async {
        do {
            let order = LoomiPlusProduct.allCases.map(\.rawValue)
            let ids = Set(order)
            let fetched = try await Product.products(for: ids)
            products = fetched.sorted { a, b in
                (order.firstIndex(of: a.id) ?? .max) < (order.firstIndex(of: b.id) ?? .max)
            }
        } catch {
            products = []
        }
    }

    @discardableResult
    func purchase(_ product: Product) async -> PurchaseOutcome {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    return .failed("Purchase couldn't be verified.")
                }
                await transaction.finish()
                await refreshEntitlement()
                return .success
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed("Something unexpected happened.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               LoomiPlusProduct(rawValue: transaction.productID) != nil {
                active = true
            }
        }
        isPlus = active
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update { await transaction.finish() }
            await refreshEntitlement()
        }
    }
}
