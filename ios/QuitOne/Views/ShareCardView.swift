import SwiftUI

enum ShareCardStyle: String, CaseIterable, Identifiable {
    case bold
    case minimal
    case dark
    case gradient
    case clean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bold: return "Bold"
        case .minimal: return "Minimal"
        case .dark: return "Dark"
        case .gradient: return "Gradient"
        case .clean: return "Clean"
        }
    }

    var isPremium: Bool {
        switch self {
        case .bold: return false
        case .minimal: return true
        case .dark: return true
        case .gradient: return true
        case .clean: return true
        }
    }
}

struct ShareCardView: View {
    let habitName: String
    let currentRunDays: Int
    let totalSaved: Double
    let dailySpend: Double
    let bestStreak: Int
    let style: ShareCardStyle

    var body: some View {
        Group {
            switch style {
            case .bold: boldCard
            case .minimal: minimalCard
            case .dark: darkCard
            case .gradient: gradientCard
            case .clean: cleanCard
            }
        }
        .frame(width: 360, height: 640)
    }

    private var boldCard: some View {
        ZStack {
            Color.white

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("DAY")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .tracking(6)
                        .foregroundStyle(Color(.systemGray3))

                    Text("\(currentRunDays)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }

                Spacer().frame(height: 16)

                Text("Still on track.")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.black.opacity(0.7))

                Spacer().frame(height: 40)

                if dailySpend > 0 && totalSaved > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.green)
                        Text("$\(Int(totalSaved)) saved")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.6))
                    }

                    Spacer().frame(height: 12)
                }

                if bestStreak > 1 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.orange)
                        Text("Best streak: \(bestStreak) days")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.black.opacity(0.45))
                    }
                }

                Spacer()

                Text("QuitOne")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.2))
                    .padding(.bottom, 32)
            }
        }
    }

    private var minimalCard: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)

            VStack(spacing: 0) {
                Spacer()

                Text("\(currentRunDays)")
                    .font(.system(size: 140, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("days strong")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black.opacity(0.4))
                    .padding(.top, -8)

                Spacer().frame(height: 48)

                if dailySpend > 0 && totalSaved > 0 {
                    Text("$\(Int(totalSaved)) saved")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.35))
                }

                Spacer()

                Text("QuitOne")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.15))
                    .padding(.bottom, 32)
            }
        }
    }

    private var darkCard: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("DAY")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(.white.opacity(0.3))

                    Text("\(currentRunDays)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("Still on track.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer().frame(height: 48)

                VStack(spacing: 10) {
                    if dailySpend > 0 && totalSaved > 0 {
                        Text("$\(Int(totalSaved)) saved")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.green.opacity(0.8))
                    }

                    if bestStreak > 1 {
                        Text("Best: \(bestStreak) days")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                Spacer()

                Text("QuitOne")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.15))
                    .padding(.bottom, 32)
            }
        }
    }

    private var gradientCard: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.56, blue: 0.42),
                    Color(red: 0.08, green: 0.35, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("DAY")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .tracking(6)
                        .foregroundStyle(.white.opacity(0.4))

                    Text("\(currentRunDays)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("Still on track.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer().frame(height: 40)

                if dailySpend > 0 && totalSaved > 0 {
                    Text("$\(Int(totalSaved)) saved")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer().frame(height: 10)
                }

                if bestStreak > 1 {
                    Text("Best streak: \(bestStreak) days")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Text("QuitOne")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.bottom, 32)
            }
        }
    }

    private var cleanCard: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.95)

            VStack(spacing: 0) {
                Spacer()

                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .overlay {
                        VStack(spacing: 2) {
                            Text("\(currentRunDays)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                            Text("days")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.green.opacity(0.6))
                        }
                    }

                Spacer().frame(height: 24)

                Text("Still on track.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))

                Spacer().frame(height: 36)

                if dailySpend > 0 && totalSaved > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(.green)
                        Text("$\(Int(totalSaved)) saved")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.5))
                    }

                    Spacer().frame(height: 10)
                }

                if bestStreak > 1 {
                    Text("Best streak: \(bestStreak) days")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.black.opacity(0.35))
                }

                Spacer()

                Text("QuitOne")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.15))
                    .padding(.bottom, 32)
            }
        }
    }
}
