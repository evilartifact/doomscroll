//
//  MeshGradientView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct MeshGradientView: View {
    let colors: [Color]
    let animationSpeed: Double
    
    @State private var animationPhase: Double = 0
    
    init(colors: [Color], animationSpeed: Double = 2.0) {
        self.colors = colors
        self.animationSpeed = animationSpeed
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated overlay gradients for mesh effect
                ForEach(0..<3, id: \.self) { index in
                    RadialGradient(
                        colors: [
                            colors[index % colors.count].opacity(0.3),
                            Color.clear
                        ],
                        center: UnitPoint(
                            x: 0.3 + 0.4 * sin(animationPhase + Double(index) * 2.0),
                            y: 0.3 + 0.4 * cos(animationPhase + Double(index) * 1.5)
                        ),
                        startRadius: 0,
                        endRadius: geometry.size.width * 0.8
                    )
                    .blendMode(.overlay)
                }
                
                // Subtle noise overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(
            .linear(duration: animationSpeed)
            .repeatForever(autoreverses: false)
        ) {
            animationPhase = .pi * 2
        }
    }
}

#Preview {
    MeshGradientView(colors: [.purple, .pink, .orange])
        .frame(width: 300, height: 200)
        .cornerRadius(20)
} 