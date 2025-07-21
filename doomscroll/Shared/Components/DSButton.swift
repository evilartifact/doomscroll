//
//  DSButton.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

enum DSButtonStyle {
    case primary
    case secondary
    case success
    case warning
    case danger
    case ghost
    case white
}

enum DSButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 48
        case .large: return 56
        }
    }
    
    var font: Font {
        switch self {
        case .small: return DesignSystem.Typography.callout
        case .medium: return DesignSystem.Typography.headline
        case .large: return DesignSystem.Typography.title2
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .small: return DesignSystem.Spacing.sm
        case .medium: return DesignSystem.Spacing.md
        case .large: return DesignSystem.Spacing.lg
        }
    }
}

struct DSButton: View {
    let title: String
    let style: DSButtonStyle
    let size: DSButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        style: DSButtonStyle = .primary,
        size: DSButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Action is handled by the gesture
        }) {
            // This ZStack now has three separate layers, just like ChapterButton
            ZStack {
                // Layer 1: The shadow rectangle (bottom)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor.opacity(0.7))
                    .offset(y: 6)

                // Layer 2: The main surface rectangle (middle)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor)
                    .offset(y: isPressed ? 6 : 0)

                // Layer 3: The text, which sits on top and moves with the surface
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, size.padding)
                    .offset(y: isPressed ? 6 : 0)
            }
            // The frame is now applied to the ZStack to contain all layers
            .frame(height: size.height)
        }
        // All of these functional modifiers remain the same
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        action()
                    }
                }
        )
    }



    private var backgroundColor: Color {
        switch style {
        case .primary: return DesignSystem.Colors.primary
        case .secondary: return DesignSystem.Colors.backgroundTertiary
        case .success: return DesignSystem.Colors.success
        case .warning: return DesignSystem.Colors.warning
        case .danger: return DesignSystem.Colors.danger
        case .ghost: return Color.clear
        case .white: return .white
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .success, .warning, .danger: return .white
        case .secondary: return DesignSystem.Colors.textPrimary
        case .ghost: return DesignSystem.Colors.primary
        case .white: return .black
        }
    }
    
}

struct DSButtonCompact: View {
    let title: String
    let style: DSButtonStyle
    let size: DSButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        style: DSButtonStyle = .primary,
        size: DSButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Action handled by gesture
        }) {
            ZStack {
                // Shadow
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor.opacity(0.7))
                    .offset(y: 6)

                // Main surface
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(backgroundColor)
                    .offset(y: isPressed ? 6 : 0)

                // Text
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                    .offset(y: isPressed ? 6 : 0)
            }
            .frame(height: size.height) // Only height, not width!
            // REMOVE any .frame(maxWidth: .infinity) here
        }
        .buttonStyle(PlainButtonStyle())
        .fixedSize() // This ensures the button sizes to its content
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        action()
                    }
                }
        )
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return DesignSystem.Colors.primary
        case .secondary: return DesignSystem.Colors.backgroundTertiary
        case .success: return DesignSystem.Colors.success
        case .warning: return DesignSystem.Colors.warning
        case .danger: return DesignSystem.Colors.danger
        case .ghost: return Color.clear
        case .white: return .white
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .success, .warning, .danger: return .white
        case .secondary: return DesignSystem.Colors.textPrimary
        case .ghost: return DesignSystem.Colors.primary
        case .white: return .black
        }
    }
    
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        DSButton("Primary Button", style: .primary) { }
        DSButton("Secondary Button", style: .secondary) { }
        DSButton("Success Button", style: .success) { }
        DSButton("Warning Button", style: .warning) { }
        DSButton("Danger Button", style: .danger) { }
        DSButton("Ghost Button", style: .ghost) { }
        
        HStack {
            DSButton("Small", style: .primary, size: .small) { }
            DSButton("Medium", style: .primary, size: .medium) { }
            DSButton("Large", style: .primary, size: .large) { }
        }
    }
    .padding()
    .background(BackgroundView())
} 
