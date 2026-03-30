import SwiftUI

struct MonthCalendarView: View {
    let store: HabitStore
    @Binding var showPaywall: Bool
    @State private var monthOffset: Int = 0
    @Environment(\.colorScheme) private var colorScheme

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
            monthNavigationHeader

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
        .background(colorScheme == .dark ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? .white.opacity(0.06) : .clear, lineWidth: 1)
        )
    }

    private var monthNavigationHeader: some View {
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
