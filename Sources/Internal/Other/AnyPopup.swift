//
//  AnyPopup.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

@MainActor
struct AnyPopup<Config: Configurable>: Popup, @preconcurrency Hashable {
    let id: String
    private let _body: AnyView
    private let _configBuilder: (Config) -> Config

    
    init(_ popup: some Popup) {
        self.id = popup.id
        self._body = AnyView(popup)
        self._configBuilder = popup.configurePopup as! (Config) -> Config
    }
    init(_ popup: some Popup, _ envObject: some ObservableObject) {
        self.id = popup.id
        self._body = AnyView(popup.environmentObject(envObject))
        self._configBuilder = popup.configurePopup as! (Config) -> Config
    }
}
extension AnyPopup {
    @MainActor func createContent() -> some View { _body }
    @MainActor func configurePopup(popup: Config) -> Config { _configBuilder(popup) }
}

// MARK: - Hashable
extension AnyPopup {
    nonisolated static func == (lhs: AnyPopup<Config>, rhs: AnyPopup<Config>) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
