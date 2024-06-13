//
//  Popup.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

@MainActor
public protocol Popup: View {
    associatedtype Config: Configurable
    associatedtype V: View

    @MainActor var id: String { get }

    @MainActor func createContent() -> V
    @MainActor func configurePopup(popup: Config) -> Config
}

@MainActor
public extension Popup {
    var id: String { .init(describing: Self.self) }
    var body: V { createContent() }

    func configurePopup(popup: Config) -> Config { popup }
}

// MARK: - Helpers
@MainActor
extension Popup {
    func remove() { PopupManager.performOperation(.remove(id: id)) }
}
