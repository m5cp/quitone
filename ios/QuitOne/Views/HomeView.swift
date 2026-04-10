import SwiftUI
import Combine
import AppIntents

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
    let widgetCheckInTrigger: Int
    @State private var checkInBounce: Int = 0
    @State private var confettiTrigger: Int = 0
    @State private var showSlipConfirm: Bool = false
    @State private var insightIndex: Int = 0
    @State private var showShareCard: Bool = false
    @State private var showCheckInConfirmation: Bool = false
    @State private var showSlipConfirmation: Bool = false
    @State private var slipHapticTrigger: Int = 0
    @State private var now: Date = Date()
    @State private var visibilityHaptic: Int = 0
    @State private var showSiriTip: Bool = true
    @State private var appeared: Bool = false
    @State private var heroNumberBounce: Int = 0
    @State private var celebrationMilestone: Int? = nil
    @State private var showPaywallNudge: Bool = false
    @State private var showPaywall: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                ScrollView {
                    VStack(spacing: 28) {
                        welcomeBackBanner

                        headerSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)

                        heroCard
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)

                        actionButtons
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)

                        paywallNudgeCard

                        siriTipSection
                        savingsInsightCard
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                        shareButton
                            .opacity(appeared ? 1 : 0)

                        insightCard
                            .opacity(appeared ? 1 : 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }

                ConfettiView(trigger: confettiTrigger)
                    .allowsHitTesting(false)

                if let milestone = celebrationMilestone {
                    MilestoneCelebrationView(
                        milestone: milestone,
                        onShare: {
                            celebrationMilestone = nil
                            showShareCard = true
                        },
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                celebrationMilestone = nil
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(50)
                }
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
                guard !appeared else { return }
                withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
            .onReceive(timer) { _ in
                now = Date()
            }
            .onChange(of: widgetCheckInTrigger) { _, _ in
                withAnimation(reduceMotion ? .none : .spring(response: 0.45, dampingFraction: 0.7)) {
                    showCheckInConfirmation = true
                }
                checkInBounce += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(reduceMotion ? .none : .easeOut(duration: 0.3)) {
                        showCheckInConfirmation = false
                    }
                }
            }
            .sheet(isPresented: $showShareCard) {
                ShareProgressView(store: store, storeVM: storeVM)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(storeVM: storeVM)
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

    private var daysSinceLastCheckIn: Int {
        guard let data else { return 0 }
        let sorted = data.completionHistory.compactMap { $0.date }.sorted()
        guard let lastDate = sorted.last else { return 0 }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
    }

    private var statusMessage: String {
        guard let data else { return "" }
        if data.todayStatus == .slipped {
            return slipRecoveryMessages[insightIndex % slipRecoveryMessages.count]
        }
        if data.hasCheckedInToday {
            return "You're still on track."
        }
        if daysSinceLastCheckIn >= 3 && data.totalProgressDays > 0 {
            return "Welcome back. Pick up where you left off."
        }
        if daysSinceLastCheckIn == 2 && data.totalProgressDays > 0 {
            return "You've been away \u{2014} today's a good day to restart."
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
            ZStack {
                StreakFlameView(streakDays: data?.currentRunDays ?? 0)

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
                        .scaleEffect(heroNumberBounce > 0 ? 1.0 : 1.0)
                        .phaseAnimator([false, true], trigger: heroNumberBounce) { content, phase in
                            content
                                .scaleEffect(phase ? 1.08 : 1.0)
                        } animation: { _ in
                            .spring(response: 0.25, dampingFraction: 0.4)
                        }
                }
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
                    let previousRun = data?.currentRunDays ?? 0
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        store.checkInToday()
                        showCheckInConfirmation = true
                    }
                    checkInBounce += 1
                    confettiTrigger += 1
                    heroNumberBounce += 1

                    let newRun = store.habit?.currentRunDays ?? 0
                    let milestoneSet: Set<Int> = [7, 14, 30, 60, 100, 200, 365]
                    if milestoneSet.contains(newRun) && newRun != previousRun {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                celebrationMilestone = newRun
                            }
                        }
                    }

                    ReviewManager.shared.checkAndPrompt(streakDays: newRun)

                    let totalCheckins = store.habit?.totalProgressDays ?? 0
                    if totalCheckins == 3 && !storeVM.isPremium {
                        let nudgeDismissed = UserDefaults.standard.bool(forKey: "paywallNudgeDismissed")
                        if !nudgeDismissed {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showPaywallNudge = true
                                }
                            }
                        }
                    }

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

    private var siriTipSection: some View {
        Group {
            if data?.hasCheckedInToday != true {
                SiriTipView(intent: CheckInIntent(), isVisible: $showSiriTip)
            }
        }
    }

    private var welcomeBackBanner: some View {
        Group {
            if let data, !data.hasCheckedInToday, daysSinceLastCheckIn >= 3, data.totalProgressDays > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "hand.wave.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Welcome back!")
                            .font(.subheadline.weight(.semibold))
                        Text("You still have \(data.totalProgressDays) days of progress. Let's keep building.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(secondaryCardBackground)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .opacity(appeared ? 1 : 0)
            }
        }
    }

    private var paywallNudgeCard: some View {
        Group {
            if showPaywallNudge && !storeVM.isPremium {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("You're building real momentum")
                                .font(.subheadline.weight(.semibold))
                            Text("Unlock insights, history, and premium share cards to keep going strong.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    HStack(spacing: 12) {
                        Button {
                            showPaywall = true
                        } label: {
                            Text("See Plans")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(.rect(cornerRadius: 10))
                        }

                        Button {
                            withAnimation(.easeOut(duration: 0.25)) {
                                showPaywallNudge = false
                            }
                            UserDefaults.standard.set(true, forKey: "paywallNudgeDismissed")
                        } label: {
                            Text("Not Now")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color(.tertiarySystemGroupedBackground))
                                .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                }
                .padding(16)
                .background(secondaryCardBackground)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }

    private var insightCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkle")
                .foregroundStyle(.green)
                .font(.body)
                .accessibilityHidden(true)
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
