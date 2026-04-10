import SwiftUI

struct OnboardingView: View {
    let store: HabitStore
    @State private var step: Int = 1
    @State private var selectedHabit: HabitOption?
    @State private var customHabitName: String = ""
    @State private var dailySpend: Double = 10
    @State private var customSpendText: String = ""
    @State private var showCustomSpend: Bool = false
    @State private var goalType: GoalType = .stop
    @State private var startDate: Date = Date()
    @State private var useCustomStartDate: Bool = false

    private var habitName: String {
        selectedHabit?.name ?? customHabitName
    }

    private var isCustom: Bool {
        selectedHabit == nil && !customHabitName.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                progressBar
                Button {
                    skipOnboarding()
                } label: {
                    Text("Skip")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 24)
            }

            ScrollView {
                VStack(spacing: 32) {
                    switch step {
                    case 1: habitSelectionStep
                    case 2: moneyStep
                    case 3: startDateStep
                    case 4: goalStep
                    case 5: readyStep
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 100)
            }
            .scrollDismissesKeyboard(.interactively)

            bottomButton
        }
        .background(Color(.systemBackground))
        .animation(.smooth(duration: 0.3), value: step)
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? Color.green : Color(.tertiarySystemFill))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var habitSelectionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What would you like\nto change?")
                .font(.title.bold())

            VStack(spacing: 10) {
                ForEach(allHabitOptions) { option in
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

    private var moneyStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What do you usually\nspend per day?")
                .font(.title.bold())

            Text("This helps us show how much you're saving.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

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

    private var startDateStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("When do you want\nto start?")
                .font(.title.bold())

            VStack(spacing: 10) {
                Button {
                    withAnimation(.snappy) {
                        useCustomStartDate = false
                        startDate = Date()
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .font(.title3)
                            .foregroundStyle(!useCustomStartDate ? .white : .green)
                        Text("Today")
                            .font(.body.weight(.medium))
                            .foregroundStyle(!useCustomStartDate ? .white : .primary)
                        Spacer()
                        if !useCustomStartDate {
                            Image(systemName: "checkmark")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .background(!useCustomStartDate ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.snappy) {
                        useCustomStartDate = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(useCustomStartDate ? .white : .green)
                        Text("Pick a date")
                            .font(.body.weight(.medium))
                            .foregroundStyle(useCustomStartDate ? .white : .primary)
                        Spacer()
                        if useCustomStartDate {
                            Image(systemName: "checkmark")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                    .background(useCustomStartDate ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                if useCustomStartDate {
                    DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(.green)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What's your goal?")
                .font(.title.bold())

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

    private var readyStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: step == 4)

            Text("You're ready to start.")
                .font(.title.bold())

            Text("One day at a time.\nWe'll be here for you.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

        }
        .frame(maxWidth: .infinity)
    }

    private var bottomButton: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                if step > 1 {
                    Button {
                        withAnimation { step -= 1 }
                    } label: {
                        Text("Back")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }

                if step == 5 {
                    Button {
                        finishOnboarding()
                    } label: {
                        Text("Begin")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                } else {
                    Button {
                        advanceStep()
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canAdvance ? Color.green : Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(!canAdvance)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(.bar)
    }

    private var canAdvance: Bool {
        switch step {
        case 1:
            return selectedHabit != nil || !customHabitName.isEmpty
        default:
            return true
        }
    }

    private func advanceStep() {
        guard canAdvance else { return }
        withAnimation { step += 1 }
    }

    private func finishOnboarding() {
        var spend = dailySpend
        if showCustomSpend, let val = Double(customSpendText) {
            spend = val
        }

        let chosenDate = useCustomStartDate ? startDate : Date()

        let data = HabitData(
            habitName: habitName,
            startDate: chosenDate,
            goalType: goalType,
            dailySpend: spend,
            completionHistory: []
        )

        store.completeOnboarding(data: data)
    }

    private func skipOnboarding() {
        let data = HabitData(
            habitName: "My Habit",
            startDate: Date(),
            goalType: .stop,
            dailySpend: 10,
            completionHistory: []
        )
        store.completeOnboarding(data: data)
    }
}
