import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: Int
    let onShare: () -> Void
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiTrigger: Int = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    private var emoji: String {
        switch milestone {
        case 7: return "🔥"
        case 14: return "⚡️"
        case 30: return "⭐️"
        case 60: return "💎"
        case 100: return "🏆"
        case 200: return "👑"
        case 365: return "🎯"
        default: return "✨"
        }
    }

    private var title: String {
        switch milestone {
        case 7: return "One week strong!"
        case 14: return "Two weeks — incredible!"
        case 30: return "One month — amazing!"
        case 60: return "Two months of power!"
        case 100: return "Triple digits!"
        case 200: return "200 days — unstoppable!"
        case 365: return "One full year!"
        default: return "Milestone reached!"
        }
    }

    private var subtitle: String {
        switch milestone {
        case 7: return "You just proved you can do this."
        case 14: return "Two weeks of showing up for yourself."
        case 30: return "A full month of real change."
        case 60: return "This is who you are now."
        case 100: return "Most people never get here."
        case 200: return "You've built something unbreakable."
        case 365: return "365 days. A whole new you."
        default: return "Keep going — you're building something real."
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.green, .mint, .green],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Text(emoji)
                        .font(.system(size: 56))
                }

                VStack(spacing: 10) {
                    Text(title)
                        .font(.title2.bold())

                    Text("\(milestone) days")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.green)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                VStack(spacing: 12) {
                    Button {
                        onShare()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.semibold))
                            Text("Share This Milestone")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.22, green: 0.78, blue: 0.38), Color(red: 0.16, green: 0.68, blue: 0.30)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Keep Going")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(colorScheme == .dark ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : .clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 30, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)

            ConfettiView(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiTrigger += 1
            }
        }
        .sensoryFeedback(.success, trigger: confettiTrigger)
    }
}
