import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isActive: Bool = false

    let trigger: Int
    let colors: [Color] = [
        .green, Color(red: 0.4, green: 1.0, blue: 0.6),
        .mint, .yellow, .cyan, .white
    ]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                particle.shape
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * particle.aspectRatio)
                    .rotationEffect(.degrees(particle.rotation))
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            launchConfetti()
        }
    }

    private func launchConfetti() {
        particles = (0..<50).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .green,
                size: CGFloat.random(in: 4...10),
                aspectRatio: CGFloat.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360),
                x: CGFloat.random(in: -20...20),
                y: 0,
                opacity: 1,
                shape: [AnyShape(Circle()), AnyShape(Rectangle()), AnyShape(Capsule())].randomElement()!
            )
        }

        for i in particles.indices {
            let targetX = CGFloat.random(in: -180...180)
            let targetY = CGFloat.random(in: -500 ... -100)
            let targetRot = Double.random(in: -720...720)
            let duration = Double.random(in: 0.8...1.4)
            let delay = Double.random(in: 0...0.3)

            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[i].x = targetX
                particles[i].y = targetY
                particles[i].rotation = targetRot
            }

            withAnimation(.easeIn(duration: 0.6).delay(delay + duration * 0.6)) {
                particles[i].opacity = 0
                particles[i].y = targetY + 200
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            particles = []
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let aspectRatio: CGFloat
    var rotation: Double
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    let shape: AnyShape
}
