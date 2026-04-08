import SwiftUI

struct StreakFlameView: View {
    let streakDays: Int
    @State private var flamePhase: CGFloat = 0
    @State private var glowPulse: Bool = false

    private var flameIntensity: Double {
        switch streakDays {
        case 0: return 0
        case 1...6: return 0.4
        case 7...29: return 0.6
        case 30...99: return 0.8
        default: return 1.0
        }
    }

    private var flameColors: [Color] {
        switch streakDays {
        case 0: return [.clear]
        case 1...6: return [.green.opacity(0.3), .green.opacity(0.1)]
        case 7...29: return [.green.opacity(0.5), .mint.opacity(0.3), .green.opacity(0.1)]
        case 30...99: return [.green, .mint.opacity(0.5), .cyan.opacity(0.2)]
        default: return [.green, .yellow.opacity(0.5), .cyan.opacity(0.3)]
        }
    }

    var body: some View {
        ZStack {
            if streakDays > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: flameColors,
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(glowPulse ? 1.15 : 1.0)
                    .opacity(flameIntensity * 0.6)
                    .blur(radius: 20)

                if streakDays >= 7 {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 6, height: 6)
                            .offset(
                                x: cos(flamePhase + Double(i) * 2.1) * 50,
                                y: sin(flamePhase + Double(i) * 2.1) * 50
                            )
                    }
                }
            }
        }
        .onAppear {
            guard streakDays > 0 else { return }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                flamePhase = .pi * 2
            }
        }
    }
}

struct MilestonePopup: View {
    let milestone: Int
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    private var milestoneEmoji: String {
        switch milestone {
        case 7: return "🔥"
        case 30: return "⭐️"
        case 60: return "💎"
        case 100: return "🏆"
        case 200: return "👑"
        case 365: return "🎯"
        default: return "✨"
        }
    }

    private var milestoneMessage: String {
        switch milestone {
        case 7: return "One week strong!"
        case 30: return "One month — incredible!"
        case 60: return "Two months of power!"
        case 100: return "Triple digits — legendary!"
        case 200: return "200 days — unstoppable!"
        case 365: return "One full year — you did it!"
        default: return "Amazing milestone!"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(milestoneEmoji)
                .font(.system(size: 48))

            Text(milestoneMessage)
                .font(.headline)
                .foregroundStyle(.white)

            Text("\(milestone) days")
                .font(.title2.bold())
                .foregroundStyle(.green)
        }
        .padding(28)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
