//
//  Public+Popup.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - Presenting
public extension Popup {
    /// Displays the popup. Stacks previous one
    @MainActor
    @discardableResult func showAndStack() -> some Popup { PopupManager.showAndStack(AnyPopup<Config>(self)); return self }

    /// Displays the popup. Closes previous one
    @MainActor
    @discardableResult func showAndReplace() -> some Popup { PopupManager.showAndReplace(AnyPopup<Config>(self)); return self }
}

// MARK: - Modifiers
public extension Popup {
    /// Closes popup after n seconds
    @MainActor
    @discardableResult func dismissAfter(_ seconds: Double) -> some Popup { PopupManager.dismissPopupAfter(self, seconds); return self }

    /// Hides the overlay for the selected popup
    @MainActor
    @discardableResult func hideOverlay() -> some Popup { PopupManager.hideOverlay(self); return self }

    /// Supplies an observable object to a view’s hierarchy.
    @MainActor
    @discardableResult func environmentObject<T: ObservableObject>(_ object: T) -> any Popup { AnyPopup<Config>(self, object) }
}

// MARK: - Available Popups
public protocol TopPopup: Popup { associatedtype Config = TopPopupConfig }
public protocol CentrePopup: Popup { associatedtype Config = CentrePopupConfig }
public protocol BottomPopup: Popup { associatedtype Config = BottomPopupConfig }
