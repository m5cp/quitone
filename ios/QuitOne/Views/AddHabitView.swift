import SwiftUI

struct AddHabitView: View {
    let store: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHabit: HabitOption?
    @State private var customHabitName: String = ""
    @State private var dailySpend: Double = 10
    @State private var customSpendText: String = ""
    @State private var showCustomSpend: Bool = false
    @State private var goalType: GoalType = .stop
    @State private var step: Int = 1

    private var habitName: String {
        selectedHabit?.name ?? customHabitName
    }

    private var isCustom: Bool {
        selectedHabit == nil && !customHabitName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    switch step {
                    case 1: habitStep
                    case 2: spendStep
                    case 3: goalStep
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        if step < 3 {
                            withAnimation { step += 1 }
                        } else {
                            addHabit()
                        }
                    } label: {
                        Text(step == 3 ? "Add Habit" : "Continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canAdvance ? Color.green : Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(!canAdvance)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .background(.bar)
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 1: return selectedHabit != nil || !customHabitName.isEmpty
        default: return true
        }
    }

    private var habitStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What habit would you\nlike to track?")
                .font(.title2.bold())

            let existing = Set(store.habits.map(\.habitName))

            VStack(spacing: 10) {
                ForEach(allHabitOptions.filter { !existing.contains($0.name) }) { option in
                    Button {
                        withAnimation(.snappy) {
                            selectedHabit = option
                            customHabitName = ""
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.icon)
                                .font(.body)
                                .foregroundStyle(selectedHabit?.id == option.id ? .white : .green)
                                .frame(width: 28)
                            Text(option.name)
                                .font(.body.weight(.medium))
                                .foregroundStyle(selectedHabit?.id == option.id ? .white : .primary)
                            Spacer()
                            if selectedHabit?.id == option.id {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedHabit?.id == option.id ? Color.green : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.snappy) {
                        selectedHabit = nil
                        customHabitName = ""
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundStyle(isCustom ? .white : .green)
                            .frame(width: 28)
                        Text("Custom Habit")
                            .font(.body.weight(.medium))
                            .foregroundStyle(isCustom ? .white : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isCustom ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            if selectedHabit == nil {
                TextField("Name your habit", text: $customHabitName)
                    .font(.body)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var spendStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What do you usually\nspend per day?")
                .font(.title2.bold())

            VStack(spacing: 10) {
                ForEach([5.0, 10.0, 15.0, 20.0], id: \.self) { amount in
                    Button {
                        withAnimation(.snappy) {
                            dailySpend = amount
                            showCustomSpend = false
                        }
                    } label: {
                        HStack {
                            Text("$\(Int(amount)) per day")
                                .font(.body.weight(.medium))
                                .foregroundStyle(!showCustomSpend && dailySpend == amount ? .white : .primary)
                            Spacer()
                            if !showCustomSpend && dailySpend == amount {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(16)
                        .background(!showCustomSpend && dailySpend == amount ? Color.green : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.snappy) { showCustomSpend = true }
                } label: {
                    HStack {
                        Text("Custom amount")
                            .font(.body.weight(.medium))
                            .foregroundStyle(showCustomSpend ? .white : .primary)
                        Spacer()
                    }
                    .padding(16)
                    .background(showCustomSpend ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                if showCustomSpend {
                    HStack {
                        Text("$")
                            .font(.title2.bold())
                        TextField("0", text: $customSpendText)
                            .font(.title2.bold())
                            .keyboardType(.decimalPad)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What's your goal?")
                .font(.title2.bold())

            VStack(spacing: 10) {
                goalButton(goal: .stop, label: "Stop completely", icon: "xmark.circle.fill")
                goalButton(goal: .reduce, label: "Reduce over time", icon: "arrow.down.circle.fill")
            }
        }
    }

    private func goalButton(goal: GoalType, label: String, icon: String) -> some View {
        Button {
            withAnimation(.snappy) { goalType = goal }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(goalType == goal ? .white : .green)
                Text(label)
                    .font(.body.weight(.medium))
                    .foregroundStyle(goalType == goal ? .white : .primary)
                Spacer()
                if goalType == goal {
                    Image(systemName: "checkmark")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
            .background(goalType == goal ? Color.green : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func addHabit() {
        var spend = dailySpend
        if showCustomSpend, let val = Double(customSpendText) {
            spend = val
        }

        let data = HabitData(
            habitName: habitName,
            startDate: Date(),
            goalType: goalType,
            dailySpend: spend,
            completionHistory: []
        )

        store.addHabit(data: data)
        dismiss()
    }
}
