import SwiftUI

struct WeeklySummaryCardContent: View {
    let store: HabitStore
    let data: HabitData
    let subtleTextColor: Color
    let sectionCardBg: Color
    let cardBorderColor: Color

    var body: some View {
        let daysOn: Int = store.daysOnTrack(last: 7)
        let rate: Double = store.completionRate(last: 7)
        let saved: Double = store.savedAmount(last: 7)
        let prevDaysOn: Int = store.previousPeriodDaysOnTrack(last: 7)
        let diff: Int = daysOn - prevDaysOn

        VStack(spacing: 18) {
            HStack {
                Text("This Week")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("\(daysOn)")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("of 7 days")
                        .font(.caption)
                        .foregroundStyle(subtleTextColor)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack(spacing: 5) {
                    Text("\(Int(rate * 100))%")
                        .font(.title.bold())
                        .foregroundStyle(rate >= 0.7 ? .green : .orange)
                    Text("consistency")
                        .font(.caption)
                        .foregroundStyle(subtleTextColor)
                }
                .frame(maxWidth: .infinity)

                if data.dailySpend > 0 {
                    Divider().frame(height: 40)

                    VStack(spacing: 5) {
                        Text("$\(Int(saved))")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                        Text("saved")
                            .font(.caption)
                            .foregroundStyle(subtleTextColor)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            weekDots

            comparisonRow(diff: diff)
        }
        .padding(18)
        .background(sectionCardBg)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
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
                        .foregroundStyle(subtleTextColor)

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

    private func comparisonRow(diff: Int) -> some View {
        Group {
            if diff > 0 {
                comparisonLabel(text: "+\(diff) better than last week", color: .green, icon: "arrow.up.right")
            } else if diff == 0 {
                comparisonLabel(text: "Same as last week", color: .blue, icon: "equal")
            } else {
                comparisonLabel(text: "Slight dip from last week", color: .orange, icon: "arrow.down.right")
            }
        }
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
}

struct MonthlySummarySectionContent: View {
    let store: HabitStore
    let data: HabitData
    @Binding var showPaywall: Bool
    let subtleTextColor: Color
    let sectionCardBg: Color
    let cardBorderColor: Color
    let colorScheme: ColorScheme

    var body: some View {
        if store.isPremium {
            monthlySummaryContent
                .background(sectionCardBg)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cardBorderColor, lineWidth: 1)
                )
        } else {
            lockedMonthlyContent
        }
    }

    private var lockedMonthlyContent: some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 0) {
                monthlySummaryContent
                    .blur(radius: 4)
                    .allowsHitTesting(false)

                Rectangle()
                    .fill(colorScheme == .dark ? .white.opacity(0.06) : Color(.separator).opacity(0.3))
                    .frame(height: 1)

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
            .background(sectionCardBg)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cardBorderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var monthlySummaryContent: some View {
        let daysOn: Int = store.daysOnTrack(last: 30)
        let rate: Double = store.completionRate(last: 30)
        let saved: Double = store.savedAmount(last: 30)
        let streak: Int = store.longestStreak(last: 30)
        let milestone: Int? = store.nextMilestone()

        return VStack(spacing: 16) {
            HStack {
                Text("Last 30 Days")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("\(daysOn)")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                    Text("days on track")
                        .font(.caption)
                        .foregroundStyle(subtleTextColor)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack(spacing: 5) {
                    Text("\(Int(rate * 100))%")
                        .font(.title.bold())
                        .foregroundStyle(rate >= 0.7 ? .green : .orange)
                    Text("consistency")
                        .font(.caption)
                        .foregroundStyle(subtleTextColor)
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
        .padding(18)
    }
}

struct MilestoneCardContent: View {
    let data: HabitData
    let subtleTextColor: Color
    let sectionCardBg: Color
    let cardBorderColor: Color

    private var run: Int { data.currentRunDays }

    private let milestones: [(Int, String)] = [
        (7, "One Week"),
        (30, "One Month"),
        (60, "Two Months"),
        (100, "100 Days"),
    ]

    var body: some View {
        let reached = milestones.filter { run >= $0.0 }
        let next = milestones.first { run < $0.0 }

        if !reached.isEmpty || next != nil {
            VStack(alignment: .leading, spacing: 16) {
                Text("Milestones")
                    .font(.headline)

                if let next {
                    let progress: Double = Double(run) / Double(next.0)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(next.1)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(run)/\(next.0) days")
                                .font(.caption)
                                .foregroundStyle(subtleTextColor)
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
                                .foregroundStyle(subtleTextColor)
                        }
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
    }
}

struct SavingsCardContent: View {
    let data: HabitData
    let subtleTextColor: Color
    let sectionCardBg: Color
    let cardBorderColor: Color
    let colorScheme: ColorScheme

    var body: some View {
        if data.dailySpend > 0 {
            HStack(spacing: 16) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 44, height: 44)
                    .background(Color.green.opacity(colorScheme == .dark ? 0.15 : 0.10))
                    .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Estimated Savings")
                        .font(.caption)
                        .foregroundStyle(subtleTextColor)
                    Text("$\(Int(data.totalSaved))")
                        .font(.title2.bold())
                    Text("Based on $\(Int(data.dailySpend))/day")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(sectionCardBg)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cardBorderColor, lineWidth: 1)
            )
        }
    }
}

struct InsightsSectionContent: View {
    let store: HabitStore
    let data: HabitData
    @Binding var showPaywall: Bool
    let subtleTextColor: Color
    let sectionCardBg: Color
    let cardBorderColor: Color
    let colorScheme: ColorScheme

    var body: some View {
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
                proInsightsContent
            } else {
                lockedInsightsPreview
            }
        }
    }

    private var proInsightsContent: some View {
        let rate7: Double = store.completionRate(last: 7)
        let rate30: Double = store.completionRate(last: 30)
        let saved7: Double = store.savedAmount(last: 7)

        return VStack(spacing: 12) {
            insightRow(icon: "chart.line.uptrend.xyaxis", title: "7-Day Success Rate", value: "\(Int(rate7 * 100))%", color: rate7 >= 0.7 ? .green : .orange)
            insightRow(icon: "calendar.badge.clock", title: "30-Day Success Rate", value: "\(Int(rate30 * 100))%", color: rate30 >= 0.7 ? .green : .orange)

            if data.dailySpend > 0 {
                insightRow(icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90", title: "This Week Saved", value: "$\(Int(saved7))", color: .green)
            }

            insightRow(icon: "flame.fill", title: "Best Streak", value: "\(store.bestRun()) days", color: .orange)

            if data.totalProgressDays > 0 {
                let avgPerWeek: Double = Double(data.totalProgressDays) / max(1, Double(store.daysSinceStart())) * 7
                insightRow(icon: "chart.bar.fill", title: "Avg Days On Track / Week", value: String(format: "%.1f", avgPerWeek), color: .blue)
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
                .padding(18)
                .blur(radius: 3)

                Rectangle()
                    .fill(colorScheme == .dark ? .white.opacity(0.06) : Color(.separator).opacity(0.3))
                    .frame(height: 1)

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
            .background(sectionCardBg)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cardBorderColor, lineWidth: 1)
            )
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
}
