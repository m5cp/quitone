import SwiftUI
import Combine

nonisolated enum CalendarViewMode: String, CaseIterable, Sendable {
    case week
    case month
}

struct HabitProgressView: View {
    let store: HabitStore
    @State private var viewMode: CalendarViewMode = .week
    @State private var showPaywall: Bool = false
    @State private var showShareProgress: Bool = false
    @State private var now: Date = Date()
    @Environment(\.colorScheme) private var colorScheme

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var data: HabitData? { store.habit }

    private var sectionCardBg: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.10, blue: 0.12)
            : Color(.secondarySystemGroupedBackground)
    }

    private var cardBorderColor: Color {
        colorScheme == .dark ? .white.opacity(0.06) : .clear
    }

    private var subtleTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.4) : .secondary
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let data {
                    VStack(spacing: 24) {
                        liveSummaryCard(data: data)
                        statsGrid(data: data)
                        calendarSection(data: data)
                        weeklySummaryCard(data: data)
                        monthlySummarySection(data: data)
                        milestoneCard(data: data)
                        savingsCard(data: data)
                        insightsSection(data: data)
                        shareProgressCard(data: data)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                } else {
                    emptyState
                }
            }
            .background(screenBackground)
            .navigationTitle("Progress")
            .onReceive(timer) { _ in
                now = Date()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showShareProgress) {
                ShareProgressView(store: store)
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

    private func liveSummaryCard(data: HabitData) -> some View {
        let interval = now.timeIntervalSince(data.startDate)
        let totalHours: Int = max(0, Int(interval / 3600))
        let days: Int = totalHours / 24
        let hours: Int = totalHours % 24
        let elapsedStr: String = days == 0
            ? "\(hours) hour\(hours == 1 ? "" : "s")"
            : "\(days) day\(days == 1 ? "" : "s"), \(hours) hour\(hours == 1 ? "" : "s")"

        return VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Time on this journey")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(subtleTextColor)
                    Text(elapsedStr)
                        .font(.title3.weight(.bold))
                }
                Spacer()
            }

            if data.dailySpend > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Total money saved")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(subtleTextColor)
                        Text("$\(Int(data.totalSaved))")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(sectionCardBg)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }

    private func statsGrid(data: HabitData) -> some View {
        HStack(spacing: 12) {
            statCard(title: "Current Run", value: "\(data.currentRunDays)", unit: "days", color: .green)
            statCard(title: "Total", value: "\(data.totalProgressDays)", unit: "days", color: .blue)
            statCard(title: "Best Run", value: "\(store.bestRun())", unit: "days", color: .orange)
        }
    }

    private func statCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(subtleTextColor)
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(subtleTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(sectionCardBg)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }

    private func calendarSection(data: HabitData) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("History")
                    .font(.headline)
                Spacer()
                Picker("View", selection: $viewMode) {
                    Text("Week").tag(CalendarViewMode.week)
                    Text("Month").tag(CalendarViewMode.month)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .onChange(of: viewMode) { _, newValue in
                    if newValue == .month && !store.isPremium {
                        viewMode = .week
                        showPaywall = true
                    }
                }
            }

            if viewMode == .week {
                WeekCalendarView(store: store)
            } else {
                MonthCalendarView(store: store, showPaywall: $showPaywall)
            }
        }
    }

    private func weeklySummaryCard(data: HabitData) -> some View {
        WeeklySummaryCardContent(store: store, data: data, subtleTextColor: subtleTextColor, sectionCardBg: sectionCardBg, cardBorderColor: cardBorderColor)
    }

    private func monthlySummarySection(data: HabitData) -> some View {
        MonthlySummarySectionContent(store: store, data: data, showPaywall: $showPaywall, subtleTextColor: subtleTextColor, sectionCardBg: sectionCardBg, cardBorderColor: cardBorderColor, colorScheme: colorScheme)
    }

    private func milestoneCard(data: HabitData) -> some View {
        MilestoneCardContent(data: data, subtleTextColor: subtleTextColor, sectionCardBg: sectionCardBg, cardBorderColor: cardBorderColor)
    }

    private func savingsCard(data: HabitData) -> some View {
        SavingsCardContent(data: data, subtleTextColor: subtleTextColor, sectionCardBg: sectionCardBg, cardBorderColor: cardBorderColor, colorScheme: colorScheme)
    }

    private func insightsSection(data: HabitData) -> some View {
        InsightsSectionContent(store: store, data: data, showPaywall: $showPaywall, subtleTextColor: subtleTextColor, sectionCardBg: sectionCardBg, cardBorderColor: cardBorderColor, colorScheme: colorScheme)
    }

    private func shareProgressCard(data: HabitData) -> some View {
        ProgressSharePremiumCard(
            day: data.currentRunDays,
            moneySavedText: data.dailySpend > 0 ? "$\(Int(data.totalSaved)) saved" : "",
            isPremiumUnlocked: store.isPremium
        ) {
            if store.isPremium {
                showShareProgress = true
            } else {
                showPaywall = true
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Your progress will build here.",
            systemImage: "chart.bar.fill",
            description: Text("Check in each day to see your journey grow.")
        )
    }
}

struct ActivityViewRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
