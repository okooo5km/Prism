//
//  Ext+Button.swift
//  HiPixel
//
//  Created by okooo5km(十里) on 2025/1/18.
//

import SwiftUI

// 1. Define configuration struct
struct GradientButtonConfiguration {
    // Basic style
    var cornerRadius: CGFloat = 12
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 8

    // Color configuration
    var startColor: Color = Color(hex: "#55AAEF")!
    var endColor: Color = .blue
    var foregroundColor: Color = .white

    // Gradient direction
    var gradientStartPoint: UnitPoint = .top
    var gradientEndPoint: UnitPoint = .bottom

    // Border configuration
    var borderWidth: CGFloat = 1
    var borderStartColor: Color = .white.opacity(0.5)
    var borderEndColor: Color = .white.opacity(0.12)

    // Interaction effects
    var pressedScale: CGFloat = 0.95
    var pressedOpacity: Double = 0.8
    var animation: Animation = .easeInOut(duration: 0.2)

    // Shadow configuration
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0

    // Disabled state configuration
    var disabledOpacity: Double = 0.6

    static let `default` = GradientButtonConfiguration()
}

// Define simple configuration struct
struct SimpleButtonConfiguration<S> where S: ShapeStyle {
    // Basic style
    var cornerRadius: CGFloat = 12
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 12
    
    // Color configuration
    var foregroundColor: Color = .primary
    var background: S
    
    // Border configuration
    var borderWidth: CGFloat = 1
    var borderColor: Color = .primary.opacity(0.1)
    
    // Interaction effects
    var pressedScale: CGFloat = 0.95
    var pressedOpacity: Double = 0.8
    var animation: Animation = .easeInOut(duration: 0.2)
    
    // Shadow configuration
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0
    
    // Disabled state configuration
    var disabledOpacity: Double = 0.6
    
    init(background: S) {
        self.background = background
    }
    
    static func `default`() -> SimpleButtonConfiguration<AnyShapeStyle> {
        SimpleButtonConfiguration<AnyShapeStyle>(background: AnyShapeStyle(.background.opacity(0.8)))
    }
}

// 2. Define button style
struct GradientButtonStyle: ButtonStyle {
    let configuration: GradientButtonConfiguration
    @Environment(\.isEnabled) private var isEnabled

    init(configuration: GradientButtonConfiguration = .default) {
        self.configuration = configuration
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(self.configuration.foregroundColor)
            .padding(.horizontal, self.configuration.horizontalPadding)
            .padding(.vertical, self.configuration.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: self.configuration.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                self.configuration.startColor,
                                self.configuration.endColor,
                            ],
                            startPoint: self.configuration.gradientStartPoint,
                            endPoint: self.configuration.gradientEndPoint
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: self.configuration.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                self.configuration.borderStartColor,
                                self.configuration.borderEndColor,
                            ],
                            startPoint: self.configuration.gradientStartPoint,
                            endPoint: self.configuration.gradientEndPoint
                        ),
                        lineWidth: self.configuration.borderWidth
                    )
            )
            .shadow(
                color: self.configuration.shadowColor,
                radius: self.configuration.shadowRadius,
                x: self.configuration.shadowX,
                y: self.configuration.shadowY
            )
            .scaleEffect(configuration.isPressed ? self.configuration.pressedScale : 1.0)
            .opacity(configuration.isPressed ? self.configuration.pressedOpacity : 1.0)
            .opacity(isEnabled ? 1.0 : self.configuration.disabledOpacity)
            .animation(self.configuration.animation, value: configuration.isPressed)
    }
}

// Define button style
struct SimpleButtonStyle: ButtonStyle {
    let configuration: SimpleButtonConfiguration<AnyShapeStyle>
    
    @Environment(\.isEnabled) private var isEnabled
    
    init(configuration: SimpleButtonConfiguration<AnyShapeStyle> = .default()) {
        self.configuration = configuration
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(self.configuration.foregroundColor)
            .padding(.horizontal, self.configuration.horizontalPadding)
            .padding(.vertical, self.configuration.verticalPadding)
            .background(
                cornerRadius: self.configuration.cornerRadius,
                strokeColor: self.configuration.borderColor,
                fill: self.configuration.background
            )
            .shadow(
                color: self.configuration.shadowColor,
                radius: self.configuration.shadowRadius,
                x: self.configuration.shadowX,
                y: self.configuration.shadowY
            )
            .scaleEffect(configuration.isPressed ? self.configuration.pressedScale : 1.0)
            .opacity(configuration.isPressed ? self.configuration.pressedOpacity : 1.0)
            .opacity(isEnabled ? 1.0 : self.configuration.disabledOpacity)
            .animation(self.configuration.animation, value: configuration.isPressed)
    }
}

// 3. Add convenience extension
extension ButtonStyle where Self == GradientButtonStyle {
    static var gradient: GradientButtonStyle { .init() }
    
    static var simple: SimpleButtonStyle { .init() }

    static func gradient(
        configuration: GradientButtonConfiguration = .default
    ) -> GradientButtonStyle {
        .init(configuration: configuration)
    }
}

extension ButtonStyle where Self == SolidButtonStyle {
    static var solid: SolidButtonStyle { .init() }

    static func solid(
        configuration: SolidButtonConfiguration = SolidButtonConfiguration.default
    ) -> SolidButtonStyle {
        .init(configuration: configuration)
    }
}

// Define Solid Button Configuration
struct SolidButtonConfiguration {
    // Basic style
    var cornerRadius: CGFloat = 12
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 12

    // Color configuration
    var backgroundColor: Color = Color(nsColor: .controlBackgroundColor).opacity(0.6)
    var foregroundColor: Color = .primary

    // Border configuration
    var borderWidth: CGFloat = 0
    var borderColor: Color = .clear

    // Interaction effects
    var pressedScale: CGFloat = 0.95
    var pressedOpacity: Double = 0.8
    var animation: Animation = .easeInOut(duration: 0.2)

    // Shadow configuration
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0

    // Disabled state configuration
    var disabledOpacity: Double = 0.6
}

// Define Solid Button Style
struct SolidButtonStyle: ButtonStyle {
    let configuration: SolidButtonConfiguration
    @Environment(\.isEnabled) private var isEnabled

    init(configuration: SolidButtonConfiguration = SolidButtonConfiguration.default) {
        self.configuration = configuration
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(self.configuration.foregroundColor)
            .padding(.horizontal, self.configuration.horizontalPadding)
            .padding(.vertical, self.configuration.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: self.configuration.cornerRadius)
                    .fill(self.configuration.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: self.configuration.cornerRadius)
                    .stroke(
                        self.configuration.borderColor,
                        lineWidth: self.configuration.borderWidth
                    )
            )
            .shadow(
                color: self.configuration.shadowColor,
                radius: self.configuration.shadowRadius,
                x: self.configuration.shadowX,
                y: self.configuration.shadowY
            )
            .scaleEffect(configuration.isPressed ? self.configuration.pressedScale : 1.0)
            .opacity(configuration.isPressed ? self.configuration.pressedOpacity : 1.0)
            .opacity(isEnabled ? 1.0 : self.configuration.disabledOpacity)
            .animation(self.configuration.animation, value: configuration.isPressed)
    }
}

// 4. Preset styles
extension GradientButtonConfiguration {
    static let primary = GradientButtonConfiguration(
        startColor: Color(hex: "#55AAEF")!,
        endColor: .blue
    )
    
    static let primary2 = GradientButtonConfiguration(
        cornerRadius: 12,
        startColor: Color(hex: "#55AAEF")!,
        endColor: .blue
    )

    static let secondary = GradientButtonConfiguration(
        startColor: Color.gray.opacity(0.8),
        endColor: Color.gray
    )
    
    static let secondary2 = GradientButtonConfiguration(
        cornerRadius: 12,
        startColor: Color.primary.opacity(0.65),
        endColor: Color.primary.opacity(0.9)
    )

    static let success = GradientButtonConfiguration(
        startColor: .green.opacity(0.8),
        endColor: .green
    )
    
    static let success2 = GradientButtonConfiguration(
        cornerRadius: 12,
        startColor: .green.opacity(0.8),
        endColor: .green
    )

    static let danger = GradientButtonConfiguration(
        startColor: .pink.opacity(0.8),
        endColor: .pink
    )
    
    static let danger2 = GradientButtonConfiguration(
        cornerRadius: 12,
        startColor: .pink.opacity(0.8),
        endColor: .pink
    )

    static let fancy = GradientButtonConfiguration(
        cornerRadius: 20,
        horizontalPadding: 20,
        verticalPadding: 12,
        startColor: .purple,
        endColor: .pink,
        shadowRadius: 8,
        shadowY: 4
    )
}

// Solid Button Configuration Presets
extension SolidButtonConfiguration {
    static let `default` = SolidButtonConfiguration(
        backgroundColor: Color(nsColor: .controlBackgroundColor).opacity(0.6),
        foregroundColor: .primary,
        borderWidth: 1,
        borderColor: .primary.opacity(0.1)
    )
    
    static let primary = SolidButtonConfiguration(
        backgroundColor: .blue.opacity(0.2),
        foregroundColor: .blue
    )
    
    static let secondary = SolidButtonConfiguration(
        backgroundColor: .secondary.opacity(0.2),
        foregroundColor: .secondary
    )
    
    static let success = SolidButtonConfiguration(
        backgroundColor: .green.opacity(0.2),
        foregroundColor: .green
    )
    
    static let danger = SolidButtonConfiguration(
        backgroundColor: .red.opacity(0.2),
        foregroundColor: .red
    )
}
