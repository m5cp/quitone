import SwiftUI

struct OnboardingView: View {
    let store: HabitStore
    @State private var step: Int = 1
    @State private var selectedHabit: HabitOption?
    @State private var customHabitName: String = ""
    @State private var customHabitType: HabitType?
    @State private var dailySpend: Double = 10
    @State private var customSpendText: String = ""
    @State private var showCustomSpend: Bool = false
    @State private var dailyTimeMinutes: Int = 30
    @State private var customTimeText: String = ""
    @State private var showCustomTime: Bool = false
    @State private var frequencyLevel: FrequencyLevel = .daily
    @State private var goalType: GoalType = .stop
    @State private var appeared: Bool = false

    private var resolvedHabitType: HabitType? {
        if let selected = selectedHabit {
            return selected.type
        }
        return customHabitType
    }

    private var habitName: String {
        selectedHabit?.name ?? customHabitName
    }

    private var isCustom: Bool {
        selectedHabit == nil && !customHabitName.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView {
                VStack(spacing: 32) {
                    switch step {
                    case 1: habitSelectionStep
                    case 2: adaptiveStep
                    case 3: goalStep
                    case 4: readyStep
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
            ForEach(1...4, id: \.self) { i in
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

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(allHabitOptions) { option in
                    Button {
                        withAnimation(.snappy) {
                            selectedHabit = option
                            customHabitName = ""
                            customHabitType = nil
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: option.icon)
                                .font(.body)
                                .foregroundStyle(selectedHabit?.id == option.id ? .white : .green)
                                .frame(width: 28)
                            Text(option.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedHabit?.id == option.id ? .white : .primary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
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
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundStyle(isCustom ? .white : .green)
                            .frame(width: 28)
                        Text("Custom Habit")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isCustom ? .white : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isCustom ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            if selectedHabit == nil {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Name your habit", text: $customHabitName)
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))

                    if !customHabitName.isEmpty {
                        Text("What kind of habit is this?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            customTypeButton(label: "Costs me money", type: .money)
                            customTypeButton(label: "Takes my time", type: .time)
                            customTypeButton(label: "Affects my mindset", type: .identity)
                        }
                    }
                }
            }
        }
    }

    private func customTypeButton(label: String, type: HabitType) -> some View {
        Button {
            withAnimation(.snappy) { customHabitType = type }
        } label: {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(customHabitType == type ? .white : .primary)
                Spacer()
                if customHabitType == type {
                    Image(systemName: "checkmark")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
            }
            .padding(14)
            .background(customHabitType == type ? Color.green : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var adaptiveStep: some View {
        switch resolvedHabitType {
        case .money:
            moneyStep
        case .time:
            timeStep
        case .identity:
            identityStep
        case .none:
            EmptyView()
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

    private var timeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How much time does\nthis take daily?")
                .font(.title.bold())

            Text("This helps us show how much time you're reclaiming.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach([(15, "15 minutes"), (30, "30 minutes"), (60, "1 hour"), (120, "2+ hours")], id: \.0) { mins, label in
                    Button {
                        withAnimation(.snappy) {
                            dailyTimeMinutes = mins
                            showCustomTime = false
                        }
                    } label: {
                        HStack {
                            Text(label)
                                .font(.body.weight(.medium))
                                .foregroundStyle(!showCustomTime && dailyTimeMinutes == mins ? .white : .primary)
                            Spacer()
                            if !showCustomTime && dailyTimeMinutes == mins {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(16)
                        .background(!showCustomTime && dailyTimeMinutes == mins ? Color.green : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.snappy) { showCustomTime = true }
                } label: {
                    HStack {
                        Text("Custom")
                            .font(.body.weight(.medium))
                            .foregroundStyle(showCustomTime ? .white : .primary)
                        Spacer()
                    }
                    .padding(16)
                    .background(showCustomTime ? Color.green : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                if showCustomTime {
                    HStack {
                        TextField("0", text: $customTimeText)
                            .font(.title2.bold())
                            .keyboardType(.numberPad)
                        Text("minutes")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }

    private var identityStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How often does\nthis happen?")
                .font(.title.bold())

            VStack(spacing: 10) {
                ForEach(FrequencyLevel.allCases, id: \.self) { level in
                    Button {
                        withAnimation(.snappy) { frequencyLevel = level }
                    } label: {
                        HStack {
                            Text(level.rawValue)
                                .font(.body.weight(.medium))
                                .foregroundStyle(frequencyLevel == level ? .white : .primary)
                            Spacer()
                            if frequencyLevel == level {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(16)
                        .background(frequencyLevel == level ? Color.green : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
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
            Group {
                if step == 4 {
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
            if selectedHabit != nil { return true }
            if !customHabitName.isEmpty && customHabitType != nil { return true }
            return false
        case 2:
            return true
        case 3:
            return true
        default:
            return true
        }
    }

    private func advanceStep() {
        guard canAdvance else { return }
        if step == 1, resolvedHabitType == .identity {
            withAnimation { step = 2 }
        } else {
            withAnimation { step += 1 }
        }
    }

    private func finishOnboarding() {
        var spend: Double? = nil
        var time: Int? = nil
        var freq: FrequencyLevel? = nil

        switch resolvedHabitType {
        case .money:
            if showCustomSpend, let val = Double(customSpendText) {
                spend = val
            } else {
                spend = dailySpend
            }
        case .time:
            if showCustomTime, let val = Int(customTimeText) {
                time = val
            } else {
                time = dailyTimeMinutes
            }
        case .identity:
            freq = frequencyLevel
        case .none:
            break
        }

        let data = HabitData(
            habitName: habitName,
            habitType: resolvedHabitType ?? .identity,
            startDate: Date(),
            goalType: goalType,
            dailySpend: spend,
            dailyTimeMinutes: time,
            frequencyLevel: freq,
            completionHistory: []
        )

        store.completeOnboarding(data: data)
    }
}

extension FrequencyLevel: CaseIterable {
    nonisolated static var allCases: [FrequencyLevel] {
        [.occasionally, .daily, .multipleTimesPerDay]
    }
}
