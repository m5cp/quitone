import SwiftUI

struct HabitProgressView: View {
    let store: HabitStore
    @State private var viewMode: CalendarViewMode = .week
    @State private var showPaywall: Bool = false
    @State private var showShareProgress: Bool = false

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let data {
                    VStack(spacing: 24) {
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
            .sheet(isPresented: $showShareProgress) {
                ShareProgressView(store: store)
            }
        }
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

    private func weeklySummaryCard(data: HabitData) -> some View {
        let daysOn = store.daysOnTrack(last: 7)
        let rate = store.completionRate(last: 7)
        let saved = store.savedAmount(last: 7)
        let prevDaysOn = store.previousPeriodDaysOnTrack(last: 7)
        let diff = daysOn - prevDaysOn

        return VStack(spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(daysOn)")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("of 7 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(Int(rate * 100))%")
                        .font(.title.bold())
                        .foregroundStyle(rate >= 0.7 ? .green : .orange)
                    Text("consistency")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                if data.dailySpend > 0 {
                    Divider().frame(height: 40)

                    VStack(spacing: 4) {
                        Text("$\(Int(saved))")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                        Text("saved")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            weekDots

            if diff > 0 {
                comparisonLabel(text: "+\(diff) better than last week", color: .green, icon: "arrow.up.right")
            } else if diff == 0 {
                comparisonLabel(text: "Same as last week", color: .blue, icon: "equal")
            } else {
                comparisonLabel(text: "Slight dip from last week", color: .orange, icon: "arrow.down.right")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var weekDots: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        return HStack(spacing: 6) {
            ForEach(days, id: \.self) { date in
                let status = store.statusForDate(date)
                let isToday = calendar.isDateInToday(date)

                VStack(spacing: 4) {
                    Text(shortDay(date))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)

                    Circle()
                        .fill(dotColor(status: status, isToday: isToday))
                        .frame(width: 10, height: 10)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func dotColor(status: DayStatus?, isToday: Bool) -> Color {
        switch status {
        case .completed: return .green
        case .slipped: return .orange
        case nil: return isToday ? Color.green.opacity(0.3) : Color(.tertiarySystemFill)
        }
    }

    private func shortDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private func comparisonLabel(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
    }

    private func monthlySummarySection(data: HabitData) -> some View {
        VStack(spacing: 0) {
            if store.isPremium {
                monthlySummaryContent(data: data)
            } else {
                Button {
                    showPaywall = true
                } label: {
                    VStack(spacing: 0) {
                        monthlySummaryContent(data: data)
                            .blur(radius: 4)
                            .allowsHitTesting(false)

                        Divider()

                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                            Text("Unlock Monthly Summary")
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
        }
    }

    private func monthlySummaryContent(data: HabitData) -> some View {
        let daysOn = store.daysOnTrack(last: 30)
        let rate = store.completionRate(last: 30)
        let saved = store.savedAmount(last: 30)
        let streak = store.longestStreak(last: 30)
        let milestone = store.nextMilestone()

        return VStack(spacing: 16) {
            HStack {
                Text("Last 30 Days")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(daysOn)")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                    Text("days on track")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(Int(rate * 100))%")
                        .font(.title.bold())
                        .foregroundStyle(rate >= 0.7 ? .green : .orange)
                    Text("consistency")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            if data.dailySpend > 0 {
                HStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.green)
                    Text("$\(Int(saved)) saved this month")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Longest streak: \(streak) days")
                    .font(.subheadline.weight(.medium))
                Spacer()
            }

            if let milestone {
                HStack(spacing: 10) {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.blue)
                    Text("Approaching \(milestone)-day milestone")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }
            }
        }
        .padding(16)
    }

    private func milestoneCard(data: HabitData) -> some View {
        let run = data.currentRunDays
        let milestones: [(Int, String)] = [
            (7, "One Week"),
            (30, "One Month"),
            (60, "Two Months"),
            (100, "100 Days"),
        ]

        let reached = milestones.filter { run >= $0.0 }
        let next = milestones.first { run < $0.0 }

        return Group {
            if !reached.isEmpty || next != nil {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Milestones")
                        .font(.headline)

                    if let next {
                        let progress = Double(run) / Double(next.0)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(next.1)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text("\(run)/\(next.0) days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: progress)
                                .tint(.green)
                        }
                    }

                    if !reached.isEmpty {
                        ForEach(reached.reversed(), id: \.0) { milestone in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text(milestone.1)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text("\(milestone.0) days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private func savingsCard(data: HabitData) -> some View {
        Group {
            if data.dailySpend > 0 {
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
        }
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
                lockedInsightsPreview
            }
        }
    }

    private func proInsightsContent(data: HabitData) -> some View {
        let rate7 = store.completionRate(last: 7)
        let rate30 = store.completionRate(last: 30)
        let saved7 = store.savedAmount(last: 7)

        return VStack(spacing: 12) {
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

            if data.dailySpend > 0 {
                insightRow(
                    icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90",
                    title: "This Week Saved",
                    value: "$\(Int(saved7))",
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
                let avgPerWeek = Double(data.totalProgressDays) / max(1, Double(store.daysSinceStart())) * 7
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

    private var lockedInsightsPreview: some View {
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
        guard let data = store.habit else { return false }
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        monthOffset -= 1
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
                    MonthDayCell(store: store, cell: cell, today: today)
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

    var body: some View {
        if cell.isBlank {
            Color.clear.frame(height: 32)
        } else {
            let date = cell.date ?? today
            let status = store.statusForDate(date)
            let isToday = Calendar.current.isDateInToday(date)
            let isFuture = date > today

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

                Text("\(cell.day)")
                    .font(.caption2)
                    .foregroundStyle(isFuture ? Color.gray.opacity(0.3) : (status != nil ? Color.white : Color.primary))
            }
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

struct ActivityViewRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
