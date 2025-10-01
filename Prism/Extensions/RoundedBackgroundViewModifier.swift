//
//  RoundedBackgroundViewModifier.swift
//  timeGo
//
//  Created by 十里 on 2024/3/21.
//

import SwiftUI

struct RoundedBackgroundModifier<S>: ViewModifier where S : ShapeStyle {
    
    var cornerRadius: CGFloat
    var strokeColor: Color
    var strokeWidth: CGFloat = 1
    var fill: S
    var shadow: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background {
                if shadow {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(fill)
                        .shadow(radius: 0.5, y: 0.3)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(fill)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
    }
}

extension View {
    func background<S>(
        cornerRadius: CGFloat = 8,
        strokeColor: Color = .primary.opacity(0.1),
        strokeWidth: CGFloat = 1,
        fill: S = BackgroundStyle.background.opacity(0.3),
        shadow: Bool = false
    ) -> some View where S : ShapeStyle {
        self.modifier(
            RoundedBackgroundModifier(
                cornerRadius: cornerRadius,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                fill: fill,
                shadow: shadow
            )
        )
    }
}
