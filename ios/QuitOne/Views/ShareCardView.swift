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

    var accent: Color {
        switch self {
        case .bold: return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .minimal: return .white.opacity(0.6)
        case .dark: return Color(red: 0.30, green: 0.85, blue: 0.45)
        case .gradient: return Color(red: 0.40, green: 0.90, blue: 0.65)
        case .clean: return Color(red: 0.55, green: 0.75, blue: 1.0)
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .bold:
            return [Color.black, Color(red: 0.05, green: 0.08, blue: 0.16), Color.black]
        case .minimal:
            return [Color(red: 0.06, green: 0.06, blue: 0.06), Color(red: 0.10, green: 0.10, blue: 0.12), Color(red: 0.06, green: 0.06, blue: 0.06)]
        case .dark:
            return [Color(red: 0.04, green: 0.04, blue: 0.08), Color(red: 0.08, green: 0.06, blue: 0.14), Color(red: 0.04, green: 0.04, blue: 0.08)]
        case .gradient:
            return [Color(red: 0.02, green: 0.10, blue: 0.08), Color(red: 0.06, green: 0.18, blue: 0.14), Color(red: 0.02, green: 0.10, blue: 0.08)]
        case .clean:
            return [Color(red: 0.04, green: 0.06, blue: 0.12), Color(red: 0.08, green: 0.10, blue: 0.18), Color(red: 0.04, green: 0.06, blue: 0.12)]
        }
    }

    func statusText(for days: Int) -> String {
        let identityMessages: [(range: ClosedRange<Int>, messages: [String])] = [
            (0...3, ["One day at a time.", "Still showing up.", "The journey begins."]),
            (4...13, ["Building momentum.", "Still on track.", "Progress over perfection."]),
            (14...29, ["Still showing up.", "Building something real.", "One day at a time."]),
            (30...59, ["Quietly powerful.", "Still going.", "Real change in progress."]),
            (60...99, ["Consistency speaks.", "Still on track.", "Becoming who I want to be."]),
            (100...365, ["Still going.", "This is who I am now.", "Progress over perfection."]),
        ]

        let bucket = identityMessages.first { $0.range.contains(days) }
            ?? identityMessages.last!

        let index = (days + rawValue.count) % bucket.messages.count
        return bucket.messages[index]
    }

    var bottomText: String {
        switch self {
        case .bold: return "Progress over perfection"
        case .minimal: return "One habit. One focus."
        case .dark: return "Still showing up"
        case .gradient: return "Building momentum"
        case .clean: return "One day at a time"
        }
    }
}

nonisolated enum ShareMetricStyle: Sendable {
    case moneySaved(amount: String)
    case timeReclaimed(value: String)
    case consistency(text: String)

    var icon: String {
        switch self {
        case .moneySaved: return "dollarsign.circle.fill"
        case .timeReclaimed: return "clock.fill"
        case .consistency: return "sparkles"
        }
    }

    var title: String {
        switch self {
        case .moneySaved(let amount): return "\(amount) saved"
        case .timeReclaimed(let value): return "\(value) reclaimed"
        case .consistency(let text): return text
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

    private var metric: ShareMetricStyle {
        if dailySpend > 0 && totalSaved > 0 {
            return .moneySaved(amount: "$\(Int(totalSaved))")
        } else {
            return .consistency(text: "Building consistency")
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: style.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(style.accent.opacity(0.20))
                .frame(width: 420, height: 420)
                .blur(radius: 100)
                .offset(x: 0, y: -120)

            VStack(spacing: 0) {
                Spacer(minLength: 48)

                HStack {
                    Text("QuitOne")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                    Spacer()
                }
                .padding(.horizontal, 56)

                Spacer(minLength: 40)

                VStack(spacing: 28) {
                    Text(habitName.uppercased())
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))
                        .tracking(2)

                    VStack(spacing: 6) {
                        Text("DAY")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                            .tracking(6)

                        Text("\(currentRunDays)")
                            .font(.system(size: 170, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                            .shadow(color: style.accent.opacity(0.40), radius: 20, x: 0, y: 8)
                            .overlay {
                                Text("\(currentRunDays)")
                                    .font(.system(size: 170, weight: .heavy, design: .rounded))
                                    .foregroundStyle(style.accent.opacity(0.18))
                                    .blur(radius: 10)
                                    .minimumScaleFactor(0.4)
                                    .lineLimit(1)
                            }
                    }

                    Text(style.statusText(for: currentRunDays))
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)

                    HStack(spacing: 14) {
                        Image(systemName: metric.icon)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(style.accent)

                        Text(metric.title)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 18)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.white.opacity(0.08))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(.white.opacity(0.10), lineWidth: 1)
                            )
                    )

                    RoundedRectangle(cornerRadius: 999)
                        .fill(
                            LinearGradient(
                                colors: [style.accent.opacity(0.0), style.accent, style.accent.opacity(0.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 4)
                        .padding(.horizontal, 80)

                    if bestStreak > 1 {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(style.accent.opacity(0.8))
                            Text("Best streak: \(bestStreak) days")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.60))
                        }
                    } else {
                        Text("Still building momentum")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.68))
                    }
                }
                .padding(.horizontal, 44)
                .padding(.vertical, 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 20)
                )
                .padding(.horizontal, 40)

                Spacer()

                Text(style.bottomText)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.50))
                    .padding(.bottom, 46)
            }
        }
        .frame(width: 1080, height: 1920)
    }
}
