import SwiftUI

struct HomeView: View {
    let store: HabitStore
    @State private var checkInBounce: Int = 0
    @State private var showSlipConfirm: Bool = false
    @State private var insightIndex: Int = 0
    @State private var showAddHabit: Bool = false
    @State private var showPaywall: Bool = false

    private var data: HabitData? { store.activeHabit }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if store.habits.count > 1 {
                        habitSwitcher
                    }
                    headerSection
                    heroCard
                    actionButtons
                    insightCard
                    disclaimerText
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .sensoryFeedback(.success, trigger: checkInBounce)
            .confirmationDialog("Had a slip?", isPresented: $showSlipConfirm, titleVisibility: .visible) {
                Button("Yes, but I'm keeping going") {
                    store.slipToday()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("One day doesn't erase your progress. Your total progress is preserved.")
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView(store: store)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.isPremium {
                            showAddHabit = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .onAppear {
                insightIndex = Int.random(in: 0..<insightMessages.count)
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
            return slipRecoveryMessages.randomElement() ?? "Start again today."
        }
        if data.hasCheckedInToday {
            return "Checked in today. Great work."
        }
        if data.currentRunDays > 0 {
            return onTrackMessages[insightIndex % onTrackMessages.count]
        }
        return "Ready when you are."
    }

    private var heroCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("DAY")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(2)

                Text("\(data?.currentRunDays ?? 0)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
            }

            Divider()
                .padding(.horizontal, 24)

            HStack(spacing: 0) {
                statItem(
                    title: "Current Run",
                    value: "\(data?.currentRunDays ?? 0) days"
                )
                Divider()
                    .frame(height: 36)
                statItem(
                    title: "Total Progress",
                    value: "\(data?.totalProgressDays ?? 0) days"
                )
            }

            if let data, data.dailySpend > 0 {
                Text("$\(Int(data.totalSaved)) saved")
                    .font(.headline)
                    .foregroundStyle(.green)
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
                        Text("You're on track today")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.green.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 14))
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundStyle(.orange)
                        Text("Tomorrow is a fresh start")
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 14))
                }
            } else {
                Button {
                    store.checkInToday()
                    checkInBounce += 1
                } label: {
                    Text("I stayed on track today")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .clipShape(.rect(cornerRadius: 14))
                }

                Button {
                    showSlipConfirm = true
                } label: {
                    Text("I had a slip — keep going")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
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

    private var disclaimerText: some View {
        Text("QuitOne is not medical advice and does not replace professional health services or treatment.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}
