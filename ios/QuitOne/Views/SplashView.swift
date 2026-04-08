import SwiftUI

struct SplashView: View {
    @State private var phase: SplashPhase = .dark
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var checkmarkTrim: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var particlesVisible: Bool = false
    @State private var glowOpacity: Double = 0
    @State private var backgroundHue: Double = 0.38

    let onFinished: () -> Void

    private enum SplashPhase {
        case dark, ringAppear, checkmark, text, particles, done
    }

    var body: some View {
        ZStack {
            background

            radialGlow

            particleField

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.green, .green.opacity(0.3), .green],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    CheckmarkShape()
                        .trim(from: 0, to: checkmarkTrim)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green, Color(red: 0.4, green: 1.0, blue: 0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 50, height: 50)
                        .opacity(checkmarkOpacity)
                }

                VStack(spacing: 10) {
                    Text("QuitOne")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)

                    Text("One day at a time")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .offset(y: subtitleOffset)
                        .opacity(subtitleOpacity)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { runSequence() }
    }

    private var background: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [
                    Color(hue: backgroundHue, saturation: 0.8, brightness: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .opacity(ringOpacity)
        }
    }

    private var radialGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.green.opacity(0.3), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 400)
            .opacity(glowOpacity)
            .scaleEffect(glowOpacity > 0 ? 1.2 : 0.8)
    }

    private var particleField: some View {
        ZStack {
            if particlesVisible {
                ForEach(0..<20, id: \.self) { i in
                    SplashParticle(index: i)
                }
            }
        }
    }

    private func runSequence() {
        withAnimation(.easeOut(duration: 0.6)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            glowOpacity = 0.8
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            checkmarkTrim = 1.0
            checkmarkOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.8)) {
            titleOffset = 0
            titleOpacity = 1
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0)) {
            subtitleOffset = 0
            subtitleOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            particlesVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeIn(duration: 0.4)) {
                ringOpacity = 0
                checkmarkOpacity = 0
                titleOpacity = 0
                subtitleOpacity = 0
                glowOpacity = 0
                particlesVisible = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            onFinished()
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.2))
        return path
    }
}

struct SplashParticle: View {
    let index: Int
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    private var angle: Double { Double(index) * (360.0 / 20.0) }
    private var distance: CGFloat { CGFloat.random(in: 100...220) }
    private var size: CGFloat { CGFloat.random(in: 3...7) }

    var body: some View {
        Circle()
            .fill(Color.green.opacity(0.8))
            .frame(width: size, height: size)
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                let rad = angle * .pi / 180
                let targetX = cos(rad) * distance
                let targetY = sin(rad) * distance
                let delay = Double(index) * 0.03

                withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                    offset = CGSize(width: targetX, height: targetY)
                    opacity = 0.9
                    scale = 1.0
                }

                withAnimation(.easeIn(duration: 0.5).delay(delay + 0.7)) {
                    opacity = 0
                    scale = 0.2
                }
            }
    }
}
