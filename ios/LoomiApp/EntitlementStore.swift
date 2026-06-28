//
//  EntitlementStore.swift
//  StoreKit 2 purchase + entitlement state for Loomi+. On-device only — no
//  server, no account, consistent with the no-tracking privacy stance.
//

import StoreKit

enum LoomiPlusProduct: String, CaseIterable {
    case monthly  = "loomi.plus.monthly"
    case annual   = "loomi.plus.annual"
    case lifetime = "loomi.plus.lifetime"
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

    deinit { updatesTask?.cancel() }

    func loadProducts() async {
        do {
            let ids = LoomiPlusProduct.allCases.map(\.rawValue)
            products = try await Product.products(for: ids).sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async {
        guard let result = try? await product.purchase() else { return }
        if case .success(let verification) = result, case .verified(let transaction) = verification {
            await transaction.finish()
            await refreshEntitlement()
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
