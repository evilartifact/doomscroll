//
//  DSSheet.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct DSSheet<Content: View>: View {
    let title: String
    let content: Content
    @Binding var isPresented: Bool
    
    init(
        title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Left: X icon with white 0.1 opacity background & border
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // Center: Title text, modern rounded font
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Right: Checkmark with white 0.1 opacity background & border
                    Button {
                        isPresented = false // or your save action
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, DesignSystem.Spacing.md)
//                .background(BackgroundView())
                
                // Content
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.vertical, 24)
                }
            }
            .background(BackgroundView())
        }
        .preferredColorScheme(.dark)
        .presentationCornerRadius(30)
    }
}

// Convenience view modifier for presenting sheets
extension View {
    func dsSheet<Content: View>(
        title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            DSSheet(title: title, isPresented: isPresented, content: content)
        }
    }
}

#Preview {
    struct SheetPreview: View {
        @State private var showSheet = false
        
        var body: some View {
            VStack {
                DSButton("Show Sheet") {
                    showSheet = true
                }
            }
            .padding()
            .background(BackgroundView())
            .dsSheet(title: "Sample Sheet", isPresented: $showSheet) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Text("Sheet Content")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    DSCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Card in Sheet")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("This demonstrates how components work together in a sheet.")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    DSButton("Action Button") {
                        // Action
                    }
                }
            }
        }
    }
    
    return SheetPreview()
} 
