//
//  DSCard.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct DSCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.lg
    
    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(
                        color: .black.opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        DSCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Card Title")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("This is a sample card with some content to demonstrate the card component.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        
        DSCard(padding: DesignSystem.Spacing.lg) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(DesignSystem.Colors.warning)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Achievement")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("First day without doomscrolling!")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    .padding()
    .background(BackgroundView())
} 
