import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    @State private var finishedAnimationCouter = 0
    let finishedAnimationLimit = 3
    
    var body: some View {
        ZStack {
            ForEach(0..<100, id: \.self) { index in
                ConfettiPiece()
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.1 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.5...3.0))
                        .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: View {
    @State private var location = CGPoint(x: 0, y: 0)
    @State private var opacity: Double = 1
    
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .mint
    ]
    
    var body: some View {
        Circle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
            .position(
                x: CGFloat.random(in: -100...UIScreen.main.bounds.width + 100),
                y: CGFloat.random(in: -100...UIScreen.main.bounds.height + 100)
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                    location = CGPoint(
                        x: CGFloat.random(in: -200...UIScreen.main.bounds.width + 200),
                        y: UIScreen.main.bounds.height + 100
                    )
                    opacity = 0
                }
            }
    }
}

struct ParticleSystem: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(.easeOut(duration: particle.duration), value: particle.position)
            }
        }
        .onAppear {
            createParticles()
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .mint]
        
        for i in 0..<50 {
            let particle = Particle(
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -50
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 6...14),
                opacity: 1.0,
                duration: Double.random(in: 2...4)
            )
            particles.append(particle)
            
            // Animate particle falling
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position = CGPoint(
                        x: CGFloat.random(in: -100...UIScreen.main.bounds.width + 100),
                        y: UIScreen.main.bounds.height + 100
                    )
                    particles[index].opacity = 0
                }
            }
        }
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            particles.removeAll()
        }
    }
}

struct Particle: Identifiable {
    let id: Int
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    let duration: Double
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        ConfettiView()
    }
} 