import SwiftUI

struct OnboardingView: View {
    let store: HabitStore
    @State private var step: Int = 0
    @State private var selectedPreset: HabitPreset?
    @State private var customName: String = ""
    @State private var dailySpend: Double = 10
    @State private var customSpendText: String = ""
    @State private var showCustomSpend: Bool = false
    @State private var selectedGoal: HabitGoal?

    private var totalSteps: Int { 4 }

    var body: some View {
        VStack(spacing: 0) {
            progressIndicator

            TabView(selection: $step) {
                habitSelectionStep.tag(0)
                spendStep.tag(1)
                goalStep.tag(2)
                readyStep.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth(duration: 0.3), value: step)
        }
        .background(Color(.systemBackground))
    }

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? Color.accentColor : Color(.systemFill))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .animation(.snappy, value: step)
    }

    // MARK: - Step 1: Habit Selection

    private var habitSelectionStep: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 12)

                Text("What would you like\nto change?")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(HabitPreset.allHabits) { preset in
                        habitCard(preset: preset)
                    }
                }
                .padding(.horizontal, 24)

                customHabitCard
                    .padding(.horizontal, 24)

                continueButton(enabled: selectedPreset != nil && (selectedPreset != .custom || !customName.isEmpty)) {
                    step = 1
                }
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func habitCard(preset: HabitPreset) -> some View {
        let isSelected = selectedPreset == preset
        return Button {
            selectedPreset = preset
            customName = ""
        } label: {
            HStack(spacing: 10) {
                Image(systemName: preset.icon)
                    .font(.body)
                    .foregroundStyle(isSelected ? .white : .accentColor)
                    .frame(width: 24)
                Text(preset.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 14))
        }
        .sensoryFeedback(.selection, trigger: selectedPreset)
    }

    private var customHabitCard: some View {
        let isSelected = selectedPreset == .custom
        return Button {
            selectedPreset = .custom
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "pencil")
                    .font(.body)
                    .foregroundStyle(isSelected ? .white : .accentColor)
                    .frame(width: 24)
                if isSelected {
                    TextField("Name your habit", text: $customName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .tint(.white)
                } else {
                    Text("Custom Habit")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    // MARK: - Step 2: Daily Spend

    private var spendStep: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 24)

            Text("What do you usually\nspend per day?")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach([5.0, 10.0, 15.0, 20.0], id: \.self) { amount in
                        spendChip(amount: amount)
                    }
                }

                Button {
                    withAnimation(.snappy) { showCustomSpend.toggle() }
                } label: {
                    Text("Custom amount")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }

                if showCustomSpend {
                    HStack {
                        Text("$")
                            .font(.title2.bold())
                            .foregroundStyle(.primary.opacity(0.5))
                        TextField("Amount", text: $customSpendText)
                            .font(.title2.bold())
                            .keyboardType(.decimalPad)
                            .onChange(of: customSpendText) { _, newValue in
                                if let value = Double(newValue), value > 0 {
                                    dailySpend = value
                                }
                            }
                    }
                    .padding()
                    .background(Color(.tertiarySystemFill))
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            continueButton(enabled: dailySpend > 0) {
                step = 2
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func spendChip(amount: Double) -> some View {
        let isSelected = dailySpend == amount && !showCustomSpend
        return Button {
            dailySpend = amount
            showCustomSpend = false
            customSpendText = ""
        } label: {
            Text("$\(Int(amount))")
                .font(.headline)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 14))
        }
        .sensoryFeedback(.selection, trigger: dailySpend)
    }

    // MARK: - Step 3: Goal

    private var goalStep: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 24)

            Text("What's your goal?")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                goalCard(goal: .stopCompletely, icon: "xmark.circle", subtitle: "Quit entirely and stay free")
                goalCard(goal: .reduceOverTime, icon: "arrow.down.circle", subtitle: "Gradually cut back over time")
            }
            .padding(.horizontal, 24)

            Spacer()

            continueButton(enabled: selectedGoal != nil) {
                step = 3
            }
        }
    }

    private func goalCard(goal: HabitGoal, icon: String, subtitle: String) -> some View {
        let isSelected = selectedGoal == goal
        return Button {
            selectedGoal = goal
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .accentColor)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .primary.opacity(0.55))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 16))
        }
        .sensoryFeedback(.selection, trigger: selectedGoal)
    }

    // MARK: - Step 4: Ready

    private var readyStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.bounce, value: step == 3)

            Text("You're ready to start.")
                .font(.title.bold())

            Text("One day at a time.")
                .font(.body.weight(.medium))
                .foregroundStyle(.primary.opacity(0.6))

            Spacer()

            Button {
                store.completeOnboarding(
                    preset: selectedPreset ?? .smoking,
                    customName: customName,
                    goal: selectedGoal ?? .stopCompletely,
                    dailySpend: dailySpend
                )
            } label: {
                Text("Begin")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: step)
        }
    }

    // MARK: - Shared

    private func continueButton(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(enabled ? Color.accentColor : Color(.systemFill))
                .foregroundStyle(enabled ? .white : .primary.opacity(0.4))
                .clipShape(.rect(cornerRadius: 16))
        }
        .disabled(!enabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
