import SwiftUI
import Combine

nonisolated enum CheckInButtonStyle {
    case onTrack
    case slip
}

struct CheckInButton: View {
    let label: String
    let style: CheckInButtonStyle
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                switch style {
                case .onTrack:
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .clipShape(.rect(cornerRadius: 14))
                case .slip:
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
        .buttonStyle(CheckInPressStyle())
    }
}

struct CheckInPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct HomeView: View {
    let store: HabitStore
    @State private var checkInBounce: Int = 0
    @State private var showSlipConfirm: Bool = false
    @State private var insightIndex: Int = 0
    @State private var showShareCard: Bool = false
    @State private var showCheckInConfirmation: Bool = false
    @State private var showSlipConfirmation: Bool = false
    @State private var slipHapticTrigger: Int = 0
    @State private var now: Date = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    heroCard
                    actionButtons
                    savingsInsightCard
                    shareButton
                    insightCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .sensoryFeedback(.success, trigger: checkInBounce)
            .sensoryFeedback(.selection, trigger: slipHapticTrigger)
            .confirmationDialog("Had a slip?", isPresented: $showSlipConfirm, titleVisibility: .visible) {
                Button("Yes, but I'm keeping going") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        store.slipToday()
                        showSlipConfirmation = true
                    }
                    slipHapticTrigger += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSlipConfirmation = false
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("One day doesn't erase your progress. Your total progress is preserved.")
            }
            .onAppear {
                insightIndex = Int.random(in: 0..<insightMessages.count)
                now = Date()
            }
            .onReceive(timer) { _ in
                now = Date()
            }
            .sheet(isPresented: $showShareCard) {
                ShareProgressView(store: store)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data?.habitName ?? "Your Habit")
                .font(.title2.bold())

            Text(statusMessage)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusMessage: String {
        guard let data else { return "" }
        if data.todayStatus == .slipped {
            return slipRecoveryMessages[insightIndex % slipRecoveryMessages.count]
        }
        if data.hasCheckedInToday {
            return "You're still on track."
        }
        if data.currentRunDays > 0 {
            return onTrackMessages[insightIndex % onTrackMessages.count]
        }
        return "Ready when you are."
    }

    private var elapsedText: String {
        guard let data else { return "" }
        let interval = now.timeIntervalSince(data.startDate)
        guard interval > 0 else { return "" }
        let totalHours = Int(interval / 3600)
        let days = totalHours / 24
        let hours = totalHours % 24
        if days == 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        return "\(days) day\(days == 1 ? "" : "s"), \(hours) hour\(hours == 1 ? "" : "s")"
    }

    private var heroCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("DAY")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(3)

                Text("\(data?.currentRunDays ?? 0)")
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
            }

            if !elapsedText.isEmpty {
                Text(elapsedText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if let data, data.dailySpend > 0 {
                Text("$\(Int(data.totalSaved)) saved")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                    .padding(.top, 4)
            }

            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)

            HStack(spacing: 0) {
                statItem(
                    title: "Current Run",
                    value: "\(data?.currentRunDays ?? 0) days"
                )
                Rectangle()
                    .fill(Color(.separator).opacity(0.3))
                    .frame(width: 1, height: 36)
                statItem(
                    title: "Total Progress",
                    value: "\(data?.totalProgressDays ?? 0) days"
                )
            }
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if data?.hasCheckedInToday == true {
                if data?.todayStatus == .completed {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, value: showCheckInConfirmation)
                        Text(showCheckInConfirmation ? "Nice work" : "You're on track today")
                            .font(.headline)
                            .foregroundStyle(.green)
                            .contentTransition(.interpolate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Color.green.opacity(showCheckInConfirmation ? 0.18 : 0.12)
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundStyle(.orange)
                        Text(showSlipConfirmation ? "Tomorrow is yours" : "Tomorrow is a fresh start")
                            .font(.headline)
                            .foregroundStyle(.orange)
                            .contentTransition(.interpolate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 14))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            } else {
                CheckInButton(label: "I stayed on track today", style: .onTrack) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        store.checkInToday()
                        showCheckInConfirmation = true
                    }
                    checkInBounce += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showCheckInConfirmation = false
                        }
                    }
                }

                CheckInButton(label: "I had a slip — keep going", style: .slip) {
                    showSlipConfirm = true
                }
            }
        }
    }

    private var savingsInsightCard: some View {
        Group {
            if let data, data.dailySpend > 0, data.totalSaved > 1 {
                let insight = savingsEquivalent(for: data.totalSaved)
                VStack(alignment: .leading, spacing: 10) {
                    Text("What your savings could cover")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    HStack(spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.title2)
                            .foregroundStyle(.green)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.text)
                                .font(.subheadline.weight(.semibold))
                            Text("$\(Int(data.totalSaved)) saved so far")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private func savingsEquivalent(for amount: Double) -> (text: String, icon: String) {
        let equivalents: [(threshold: Double, text: String, icon: String)] = [
            (5, "A fancy coffee", "cup.and.saucer.fill"),
            (12, "A movie ticket", "film.fill"),
            (15, "Lunch for the day", "fork.knife"),
            (25, "A streaming subscription", "play.tv.fill"),
            (40, "A tank of gas", "fuelpump.fill"),
            (50, "A nice dinner out", "fork.knife"),
            (75, "A pair of shoes", "shoeprints.fill"),
            (100, "A weekend getaway fund", "airplane"),
            (150, "New headphones", "headphones"),
            (200, "A short trip", "car.fill"),
            (300, "A new gadget", "iphone"),
            (500, "A vacation starter", "sun.max.fill"),
            (750, "A month's groceries", "cart.fill"),
            (1000, "A major upgrade", "star.fill"),
        ]

        var best = equivalents[0]
        for eq in equivalents {
            if amount >= eq.threshold {
                best = eq
            }
        }
        return (text: best.text, icon: best.icon)
    }

    private var shareButton: some View {
        Button {
            showShareCard = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                Text("Share Progress")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var insightCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkle")
                .foregroundStyle(.green)
            Text(insightMessages[insightIndex % insightMessages.count])
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
