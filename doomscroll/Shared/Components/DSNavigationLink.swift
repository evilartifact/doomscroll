//
//  DSNavigationLink.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct DSNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let label: Label
    
    init(
        destination: Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            label
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Convenience initializer for text labels
extension DSNavigationLink where Label == Text {
    init(_ title: String, destination: Destination) {
        self.destination = destination
        self.label = Text(title)
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: DesignSystem.Spacing.md) {
            DSNavigationLink(destination: Text("Destination View").font(.title)) {
                DSButton("Navigate with Button") { }
            }
            
            DSNavigationLink("Navigate with Text", destination: 
                VStack {
                    Text("This is the destination")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Text("Navigation with NavigationStack")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BackgroundView())
            )
            .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding()
        .background(BackgroundView())
    }
} 
