//
//  LoomiApp.swift
//  Loomi — a pocket calm companion for stressful days. (iOS 16+)
//

import SwiftUI

@main
struct LoomiApp: App {
    @StateObject private var router      = Router.shared
    @StateObject private var journal     = JournalStore()
    @StateObject private var entitlements = EntitlementStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(journal)
                .environmentObject(entitlements)
                .onOpenURL { router.open($0) }   // loomi://relief etc.
        }
    }
}
