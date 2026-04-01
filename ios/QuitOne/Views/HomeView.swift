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
    @Environment(\.colorScheme) private var colorScheme

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
                        .background(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [Color(red: 0.18, green: 0.72, blue: 0.32), Color(red: 0.14, green: 0.62, blue: 0.28)]
                                    : [Color(red: 0.22, green: 0.78, blue: 0.38), Color(red: 0.18, green: 0.70, blue: 0.32)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(color: .green.opacity(colorScheme == .dark ? 0.3 : 0.18), radius: 12, y: 4)
                case .slip:
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(slipBackground)
                        .clipShape(.rect(cornerRadius: 14))
                }
            }
        }
        .buttonStyle(CheckInPressStyle())
    }

    private var slipBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color(.tertiarySystemGroupedBackground)
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
    let storeVM: StoreViewModel
    @State private var checkInBounce: Int = 0
    @State private var showSlipConfirm: Bool = false
    @State private var insightIndex: Int = 0
    @State private var showShareCard: Bool = false
    @State private var showCheckInConfirmation: Bool = false
    @State private var showSlipConfirmation: Bool = false
    @State private var slipHapticTrigger: Int = 0
    @State private var now: Date = Date()
    @State private var visibilityHaptic: Int = 0
    @Environment(\.colorScheme) private var colorScheme

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    heroCard
                    actionButtons
                    savingsInsightCard
                    shareButton
                    insightCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(screenBackground)
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
                ShareProgressView(store: store, storeVM: storeVM)
            }
        }
    }

    private var screenBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(red: 0.04, green: 0.04, blue: 0.05)
            } else {
                Color(.systemBackground)
            }
        }
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.displayHabitName)
                    .font(.system(size: 28, weight: .bold))
                    .contentTransition(.interpolate)

                Text(statusMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.snappy(duration: 0.25)) {
                    store.habitNameHidden.toggle()
                }
                visibilityHaptic += 1
            } label: {
                Image(systemName: store.habitNameHidden ? "eye.slash" : "eye")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(.tertiarySystemGroupedBackground))
                    )
            }
            .accessibilityLabel(store.habitNameHidden ? "Show habit name" : "Hide habit name")
            .accessibilityHint("Toggles whether the habit name is visible")
        }
        .sensoryFeedback(.selection, trigger: visibilityHaptic)
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
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("DAY")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .secondary)
                    .tracking(4)

                Text("\(data?.currentRunDays ?? 0)")
                    .font(.system(size: 88, weight: .heavy, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
                    .shadow(color: .green.opacity(colorScheme == .dark ? 0.25 : 0.0), radius: 20, y: 4)
            }

            if !elapsedText.isEmpty {
                Text(elapsedText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .secondary)
            }

            if let data, data.dailySpend > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.green)
                    Text("$\(Int(data.totalSaved)) saved")
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                }
                .padding(.top, 2)
            }

            heroDivider

            HStack(spacing: 0) {
                statItem(
                    title: "Current Run",
                    value: "\(data?.currentRunDays ?? 0) days"
                )
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: 1, height: 36)
                statItem(
                    title: "Total Progress",
                    value: "\(data?.totalProgressDays ?? 0) days"
                )
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .dark ? 0 : 16, y: colorScheme == .dark ? 0 : 6)
    }

    private var heroDivider: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    private var dividerColor: Color {
        colorScheme == .dark ? .white.opacity(0.08) : Color(.separator).opacity(0.3)
    }

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.10, green: 0.10, blue: 0.12))
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemGroupedBackground))
            }
        }
    }

    private var cardBorder: Color {
        colorScheme == .dark ? .white.opacity(0.06) : .clear
    }

    private var cardShadow: Color {
        colorScheme == .dark ? .clear : .black.opacity(0.06)
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .secondary)
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
                        Color.green.opacity(showCheckInConfirmation ? 0.18 : 0.10)
                    )
                    .clipShape(.rect(cornerRadius: 16))
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
                    .background(Color.orange.opacity(0.10))
                    .clipShape(.rect(cornerRadius: 16))
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
                let insight = progressInsight(saved: data.totalSaved, dailySpend: data.dailySpend, days: data.currentRunDays)
                VStack(alignment: .leading, spacing: 12) {
                    Text("YOUR PROGRESS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.35) : .secondary)
                        .tracking(1)

                    HStack(spacing: 14) {
                        Image(systemName: insight.icon)
                            .font(.title2)
                            .foregroundStyle(.green)
                            .frame(width: 38)

                        Text(insight.text)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                }
                .padding(18)
                .background(secondaryCardBackground)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cardBorder, lineWidth: 1)
                )
            }
        }
    }

    private var secondaryCardBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.10, blue: 0.12)
            : Color(.secondarySystemGroupedBackground)
    }

    private func progressInsight(saved: Double, dailySpend: Double, days: Int) -> (text: String, icon: String) {
        let yearProjection = dailySpend * 365
        let insights: [(text: String, icon: String)] = [
            ("At this pace, that's over $\(Int(yearProjection)) kept in a year.", "chart.line.uptrend.xyaxis"),
            ("You kept $\(Int(saved)) in your control.", "hand.raised.fill"),
            ("This is how habits turn into real change.", "bolt.fill"),
            ("\(days) days of choosing differently.", "arrow.up.right"),
            ("Every day you don't spend is a day you invest in yourself.", "sparkles"),
            ("$\(Int(saved)) redirected. That's power.", "powerplug.fill"),
        ]
        let index = (Calendar.current.component(.day, from: Date()) + days) % insights.count
        return insights[index]
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
            .padding(.vertical, 15)
            .background(Color.green.opacity(colorScheme == .dark ? 0.12 : 0.08))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.green.opacity(colorScheme == .dark ? 0.2 : 0.0), lineWidth: 1)
            )
        }
    }

    private var insightCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkle")
                .foregroundStyle(.green)
                .font(.body)
            Text(insightMessages[insightIndex % insightMessages.count])
                .font(.subheadline)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.55) : .secondary)
            Spacer()
        }
        .padding(18)
        .background(secondaryCardBackground)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
}
