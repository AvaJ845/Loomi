//
//  Router.swift
//  Single source of truth for navigation. Shared so deep links (loomi://…),
//  the Home Screen widget, and the Action-button App Intent can all drive it.
//

import SwiftUI

enum Screen { case home, relief, breathe, journal, stats, insights, understand, techniques, resilience, support, settings }

final class Router: ObservableObject {
    static let shared = Router()

    @Published var screen: Screen = .home

    /// Handle loomi://relief, loomi://breathe, loomi://journal
    func open(_ url: URL) {
        switch url.host?.lowercased() {
        case "relief":  screen = .relief
        case "breathe": screen = .breathe
        case "journal": screen = .journal
        default:        break
        }
    }
}
