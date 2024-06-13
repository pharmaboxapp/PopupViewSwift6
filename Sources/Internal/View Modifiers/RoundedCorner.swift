//
//  RoundedCorner.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

extension View {
    func background(_ backgroundColour: Color, overlayColour: Color, shadow: Shadow) -> some View {
        overlay(createRoundedCorner(overlayColour))
            .background(createRoundedCorner(backgroundColour).createShadow(shadow))
    }
}
private extension View {
    func createRoundedCorner(_ colour: Color) -> some View { RoundedCorner().fill(colour) }
    func createShadow(_ shadowAttributes: Shadow) -> some View { shadow(color: shadowAttributes.color, radius: shadowAttributes.radius, x: shadowAttributes.x, y: shadowAttributes.y) }
}

// MARK: - Implementation
import SwiftUI

// MARK: - Implementation
struct RoundedCorner: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.allCorners],
            cornerRadii: CGSize(width: 50, height: 50)
        )
        return Path(path.cgPath)
    }
}
