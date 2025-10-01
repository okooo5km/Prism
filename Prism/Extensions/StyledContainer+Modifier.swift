//
//  StyledContainer+Modifier.swift
//  Orchard
//
//  Created by Claude on 2025/7/17.
//

import SwiftUI

struct StyledContainerStyle {
    var cornerRadius: CGFloat = 4
    var foregroundStyle: Color = .white
    var paddingVertical: CGFloat = 2
    var paddingHorizontal: CGFloat = 4
    var backgroundGradient: [Color] = [Color(hex: "#55AAEF") ?? .blue, .blue]
    var borderGradient: [Color] = [.white.opacity(0.5), .white.opacity(0.12)]
    var borderWidth: CGFloat = 1
    
    static let `default` = StyledContainerStyle()
    
    static let pro = StyledContainerStyle()
    
    static let free = StyledContainerStyle(
        cornerRadius: 4,
        foregroundStyle: .white,
        paddingVertical: 2,
        paddingHorizontal: 4,
        backgroundGradient: [.gray, .gray.opacity(0.8)],
        borderGradient: [.white.opacity(0.6), .white.opacity(0.1)],
        borderWidth: 1
    )
    
    static let success = StyledContainerStyle(
        cornerRadius: 4,
        foregroundStyle: .white,
        paddingVertical: 2,
        paddingHorizontal: 4,
        backgroundGradient: [.green, .green.opacity(0.8)],
        borderGradient: [.white.opacity(0.5), .white.opacity(0.12)],
        borderWidth: 1
    )
    
    static let warning = StyledContainerStyle(
        cornerRadius: 4,
        foregroundStyle: .white,
        paddingVertical: 2,
        paddingHorizontal: 4,
        backgroundGradient: [.orange, .orange.opacity(0.8)],
        borderGradient: [.white.opacity(0.5), .white.opacity(0.12)],
        borderWidth: 1
    )
    
    static let error = StyledContainerStyle(
        cornerRadius: 4,
        foregroundStyle: .white,
        paddingVertical: 2,
        paddingHorizontal: 4,
        backgroundGradient: [.red, .red.opacity(0.8)],
        borderGradient: [.white.opacity(0.5), .white.opacity(0.12)],
        borderWidth: 1
    )
    
    static let selected = StyledContainerStyle(
        cornerRadius: 12,
        foregroundStyle: .white,
        paddingVertical: 8,
        paddingHorizontal: 8,
        backgroundGradient: [Color(hex: "#55AAEF") ?? .blue, .blue],
        borderGradient: [.white.opacity(0.5), .white.opacity(0.12)],
        borderWidth: 1
    )
    
    static let notSelected = StyledContainerStyle(
        cornerRadius: 12,
        foregroundStyle: .primary,
        paddingVertical: 8,
        paddingHorizontal: 8,
        backgroundGradient: [Color(nsColor: .textBackgroundColor).opacity(0.5), Color(nsColor: .textBackgroundColor).opacity(0.6)],
        borderGradient: [.primary.opacity(0.06), .primary.opacity(0.06)],
        borderWidth: 1
    )
}

struct StyledContainerModifier: ViewModifier {
    let style: StyledContainerStyle
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(style.foregroundStyle)
            .padding(.vertical, style.paddingVertical)
            .padding(.horizontal, style.paddingHorizontal)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: style.backgroundGradient,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: style.borderGradient,
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: style.borderWidth
                    )
            )
    }
}

extension View {
    func styledContainer(style: StyledContainerStyle = .default) -> some View {
        self.modifier(StyledContainerModifier(style: style))
    }
}
