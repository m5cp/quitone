import SwiftUI

struct HabitProgressView: View {
    let store: HabitStore

    private var hasData: Bool {
        store.habitData.totalProgressDays > 0 || store.habitData.checkIns.count > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if hasData {
                    progressContent
                } else {
                    emptyState
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Progress")
        }
    }

    private var progressContent: some View {
        VStack(spacing: 20) {
            statsRow
            moneyCard
            weekView
            disclaimerText
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                value: "\(store.habitData.currentRunDays)",
                label: "Current Run",
                icon: "flame.fill",
                color: .orange
            )
            statCard(
                value: "\(store.habitData.totalProgressDays)",
                label: "Total Days",
                icon: "calendar",
                color: .accentColor
            )
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Money Card

    private var moneyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text("Estimated Savings")
                    .font(.headline)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(store.formattedSaved)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("saved")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.75))
            }

            savingsBar
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var savingsBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Current run")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.75))
                Spacer()
                Text(store.formattedCurrentRunSaved)
                    .font(.caption.bold())
            }
            GeometryReader { geo in
                let total = max(store.habitData.totalSaved, 1)
                let ratio = min(store.habitData.currentRunSaved / total, 1.0)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemFill))
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(geo.size.width * ratio, 4))
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Week View

    private var weekView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Check-ins")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(recentDays, id: \.date) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.primary.opacity(0.75))
                        Circle()
                            .fill(day.color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                if let onTrack = day.onTrack {
                                    Image(systemName: onTrack ? "checkmark" : "minus")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private struct DayInfo: Sendable {
        let date: Date
        let label: String
        let onTrack: Bool?
        var color: Color {
            guard let onTrack else { return Color(.systemFill) }
            return onTrack ? .green : .orange
        }
    }

    private var recentDays: [DayInfo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let entry = store.habitData.checkIns.first { calendar.isDate($0.date, inSameDayAs: date) }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return DayInfo(date: date, label: formatter.string(from: date), onTrack: entry?.onTrack)
        }
    }

    private var disclaimerText: some View {
        Text("Estimates are based on your input and may vary.")
            .font(.caption)
            .foregroundStyle(.primary.opacity(0.6))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "Your progress will build here.",
            systemImage: "chart.bar",
            description: Text("Check in each day to see your journey.")
        )
        .padding(.top, 60)
    }
}
