import SwiftUI

struct HabitProgressView: View {
    let store: HabitStore
    @State private var viewMode: CalendarViewMode = .week
    @State private var showPaywall: Bool = false

    private var data: HabitData? { store.activeHabit }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let data {
                    VStack(spacing: 24) {
                        if store.habits.count > 1 {
                            habitSwitcher
                        }
                        statsGrid(data: data)
                        calendarSection(data: data)
                        savingsCard(data: data)
                        insightsSection(data: data)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                } else {
                    emptyState
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Progress")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var habitSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.habits) { habit in
                    Button {
                        withAnimation(.snappy) {
                            store.switchActiveHabit(to: habit.id)
                        }
                    } label: {
                        Text(habit.habitName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(store.activeHabitId == habit.id ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(store.activeHabitId == habit.id ? Color.green : Color(.secondarySystemGroupedBackground))
                            .clipShape(.capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 0)
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
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
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

    private func savingsCard(data: HabitData) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.12))
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Estimated Savings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("$\(Int(data.totalSaved))")
                    .font(.title2.bold())
                Text("Based on $\(Int(data.dailySpend))/day")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func insightsSection(data: HabitData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Insights")
                    .font(.headline)
                Spacer()
                if !store.isPremium {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Pro")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }

            if store.isPremium {
                proInsightsContent(data: data)
            } else {
                lockedInsightsPreview(data: data)
            }
        }
    }

    private func proInsightsContent(data: HabitData) -> some View {
        VStack(spacing: 12) {
            let rate7 = store.completionRate(last: 7)
            let rate30 = store.completionRate(last: 30)
            let weekly = store.weeklySpendAvoided()

            insightRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "7-Day Success Rate",
                value: "\(Int(rate7 * 100))%",
                color: rate7 >= 0.7 ? .green : .orange
            )

            insightRow(
                icon: "calendar.badge.clock",
                title: "30-Day Success Rate",
                value: "\(Int(rate30 * 100))%",
                color: rate30 >= 0.7 ? .green : .orange
            )

            if !weekly.isEmpty {
                insightRow(
                    icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90",
                    title: "This Week Saved",
                    value: "$\(Int(weekly.last ?? 0))",
                    color: .green
                )
            }

            insightRow(
                icon: "flame.fill",
                title: "Best Streak",
                value: "\(store.bestRun()) days",
                color: .orange
            )

            if data.totalProgressDays > 0 {
                let avgPerWeek = Double(data.totalProgressDays) / max(1, Double(daysSinceStart(data: data))) * 7
                insightRow(
                    icon: "chart.bar.fill",
                    title: "Avg Days On Track / Week",
                    value: String(format: "%.1f", avgPerWeek),
                    color: .blue
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func lockedInsightsPreview(data: HabitData) -> some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    insightRow(icon: "chart.line.uptrend.xyaxis", title: "7-Day Success Rate", value: "—", color: Color(.quaternaryLabel))
                    insightRow(icon: "calendar.badge.clock", title: "30-Day Success Rate", value: "—", color: Color(.quaternaryLabel))
                    insightRow(icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90", title: "Weekly Savings Trend", value: "—", color: Color(.quaternaryLabel))
                    insightRow(icon: "chart.bar.fill", title: "Avg Days On Track / Week", value: "—", color: Color(.quaternaryLabel))
                }
                .padding(16)
                .blur(radius: 3)

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                    Text("Unlock Insights with Pro")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func insightRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
    }

    private func daysSinceStart(data: HabitData) -> Int {
        Calendar.current.dateComponents([.day], from: data.startDate, to: Date()).day ?? 0
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Your progress will build here.",
            systemImage: "chart.bar.fill",
            description: Text("Check in each day to see your journey grow.")
        )
    }
}

struct WeekCalendarView: View {
    let store: HabitStore

    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        HStack(spacing: 8) {
            ForEach(weekdays, id: \.self) { date in
                WeekDayCell(store: store, date: date)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct WeekDayCell: View {
    let store: HabitStore
    let date: Date

    var body: some View {
        let calendar = Calendar.current
        let status = store.statusForDate(date)
        let isToday = calendar.isDateInToday(date)

        VStack(spacing: 6) {
            Text(dayLetter)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)

            Circle()
                .fill(colorForStatus(status))
                .frame(width: 36, height: 36)
                .overlay {
                    if let status {
                        Image(systemName: status == .completed ? "checkmark" : "minus")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else if isToday {
                        Circle()
                            .strokeBorder(Color.green, lineWidth: 2)
                    }
                }

            Circle()
                .fill(isToday ? Color.green : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    private func colorForStatus(_ status: DayStatus?) -> Color {
        switch status {
        case .completed: return .green
        case .slipped: return Color(.systemOrange).opacity(0.7)
        case nil: return Color(.tertiarySystemFill)
        }
    }
}

struct MonthCalendarView: View {
    let store: HabitStore
    @Binding var showPaywall: Bool
    @State private var monthOffset: Int = 0

    private var displayedMonth: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var canGoForward: Bool {
        monthOffset < 0
    }

    private var canGoBack: Bool {
        guard let data = store.activeHabit else { return false }
        let calendar = Calendar.current
        let targetMonth = calendar.date(byAdding: .month, value: monthOffset - 1, to: Date()) ?? Date()
        let startMonth = calendar.dateComponents([.year, .month], from: data.startDate)
        let targetComponents = calendar.dateComponents([.year, .month], from: targetMonth)
        if let sy = startMonth.year, let sm = startMonth.month,
           let ty = targetComponents.year, let tm = targetComponents.month {
            return ty > sy || (ty == sy && tm >= sm)
        }
        return false
    }

    private var cells: [MonthCell] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let blankDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var result: [MonthCell] = []
        for i in 0..<blankDays {
            result.append(MonthCell(id: i, day: 0, date: nil, isBlank: true))
        }
        for dayIndex in 0..<range.count {
            let date = calendar.date(byAdding: .day, value: dayIndex, to: startOfMonth)
            result.append(MonthCell(id: blankDays + dayIndex, day: dayIndex + 1, date: date, isBlank: false))
        }
        return result
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        let today = Calendar.current.startOfDay(for: Date())

        VStack(spacing: 12) {
            HStack {
                Button {
                    if !store.isPremium && monthOffset <= 0 {
                        showPaywall = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            monthOffset -= 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(canGoBack ? .primary : .quaternary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(!canGoBack)

                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        monthOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(canGoForward ? .primary : .quaternary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(!canGoForward)
            }

            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                    Text(d)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(cells) { cell in
                    MonthDayCell(store: store, cell: cell, today: today, showPaywall: $showPaywall)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct MonthDayCell: View {
    let store: HabitStore
    let cell: MonthCell
    let today: Date
    @Binding var showPaywall: Bool

    var body: some View {
        if cell.isBlank {
            Color.clear.frame(height: 32)
        } else {
            let calendar = Calendar.current
            let date = cell.date ?? today
            let status = store.statusForDate(date)
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today
            let diff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
            let isInFreeRange = diff >= 0 && diff <= 6

            Button {
                if !store.isPremium && !isInFreeRange {
                    showPaywall = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isFuture ? Color.clear : colorForStatus(status))
                        .frame(width: 32, height: 32)

                    if !isFuture {
                        if let status {
                            Image(systemName: status == .completed ? "checkmark" : "minus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Color.green, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                    }

                    if !store.isPremium && !isInFreeRange && !isFuture {
                        Circle()
                            .fill(Color(.systemBackground).opacity(0.6))
                            .frame(width: 32, height: 32)
                    }

                    Text("\(cell.day)")
                        .font(.caption2)
                        .foregroundStyle(isFuture ? Color.gray.opacity(0.3) : (status != nil ? Color.white : Color.primary))
                }
            }
            .buttonStyle(.plain)
            .disabled(isFuture)
        }
    }

    private func colorForStatus(_ status: DayStatus?) -> Color {
        switch status {
        case .completed: return .green
        case .slipped: return Color(.systemOrange).opacity(0.7)
        case nil: return Color(.tertiarySystemFill)
        }
    }
}

struct MonthCell: Identifiable {
    let id: Int
    let day: Int
    let date: Date?
    let isBlank: Bool
}

enum CalendarViewMode: String, CaseIterable {
    case week
    case month
}
