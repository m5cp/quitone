import SwiftUI

struct WeekCalendarView: View {
    let store: HabitStore
    @Environment(\.colorScheme) private var colorScheme

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
        .background(colorScheme == .dark ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? .white.opacity(0.06) : .clear, lineWidth: 1)
        )
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
