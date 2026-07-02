//
//  PaywallView.swift
//  Loomi+ upsell. Leads with the lifetime plan, not monthly — per the
//  product-council reshape: a handful of lifetime buyers is a more realistic
//  path to revenue than chasing monthly-subscriber volume on a zero-budget,
//  zero-review launch, and it carries no churn risk.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    var onClose: () -> Void
    @EnvironmentObject private var store: EntitlementStore
    @State private var selected: LoomiPlusProduct = .lifetime
    @State private var purchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24)).foregroundColor(.muted)
                    }
                    .buttonStyle(.plain)
                }

                PuppyView(size: 110, happy: true)
                Text("Loomi+").font(.baloo(28, .heavy)).foregroundColor(.ink)
                Text("Your personal stress patterns — computed on this phone, never uploaded. Unlocked once and yours.")
                    .font(.text(15)).foregroundColor(.muted)
                    .multilineTextAlignment(.center).frame(maxWidth: 320)

                if store.isPlus {
                    Text("You're already Loomi+. Thank you. 🐾")
                        .font(.baloo(16, .bold)).foregroundColor(.brandRed).padding(.vertical, 20)
                } else if store.products.isEmpty {
                    ProgressView().padding(.vertical, 30)
                } else {
                    VStack(spacing: 10) {
                        ForEach(store.products, id: \.id) { product in
                            if let kind = LoomiPlusProduct(rawValue: product.id) {
                                planRow(product, kind)
                            }
                        }
                    }

                    Button {
                        guard let product = store.products.first(where: { $0.id == selected.rawValue }) else { return }
                        errorMessage = nil
                        purchasing = true
                        Task {
                            let outcome = await store.purchase(product)
                            purchasing = false
                            switch outcome {
                            case .success: onClose()
                            case .cancelled, .pending: break
                            case .failed(let message): errorMessage = message
                            }
                        }
                    } label: {
                        Text(purchasing ? "…" : "Continue")
                            .font(.baloo(18, .bold)).foregroundColor(.cream)
                            .frame(maxWidth: .infinity).padding(16)
                            .background(Color.brandRed)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(purchasing)

                    if let errorMessage {
                        Text(errorMessage).font(.text(13)).foregroundColor(.brandRed)
                            .multilineTextAlignment(.center)
                    }

                    Button("Restore purchase") { Task { await store.restore() } }
                        .font(.baloo(13)).foregroundColor(.muted).buttonStyle(.plain)
                }

                Text("Crisis resources and the stress-relief flow are always free — Loomi+ only unlocks extra depth.")
                    .font(.text(12)).foregroundColor(.muted)
                    .multilineTextAlignment(.center).frame(maxWidth: 300)
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private func planRow(_ product: Product, _ kind: LoomiPlusProduct) -> some View {
        Button { selected = kind } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: kind)).font(.baloo(16, .bold)).foregroundColor(.ink)
                    if kind == .lifetime {
                        Text("Best value — pay once, never again")
                            .font(.text(12, .semibold)).foregroundColor(.brandRed)
                    }
                }
                Spacer()
                Text(product.displayPrice).font(.baloo(16, .bold)).foregroundColor(.ink)
            }
            .padding(14)
            .background(selected == kind ? Color.roseSoft : Color.cream)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected == kind ? Color.brandRed : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func title(for kind: LoomiPlusProduct) -> String {
        switch kind {
        case .monthly:  return "Monthly"
        case .annual:   return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }
}
