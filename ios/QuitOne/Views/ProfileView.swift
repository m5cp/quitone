import SwiftUI

struct ProfileView: View {
    let store: HabitStore
    @State private var showResetAlert: Bool = false
    @State private var showResetAllAlert: Bool = false
    @State private var editingDate: Bool = false
    @State private var editDate: Date = Date()
    @State private var editingGoal: Bool = false
    @State private var showSpendEditor: Bool = false

    var body: some View {
        NavigationStack {
            List {
                headerSection
                habitSection
                notificationSection
                supportSection
                legalSection
                dangerSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationDestination(for: LegalPage.self) { page in
                LegalView(page: page)
            }
            .sheet(isPresented: $showSpendEditor) {
                DailySpendEditorView(store: store)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your progress")
                    .font(.title2.bold())
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.accentColor)
                    Text(store.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Habit Settings

    private var habitSection: some View {
        Section("Habit") {
            HStack {
                Label(store.habitData.habitName, systemImage: store.habitData.preset.icon)
                Spacer()
            }

            Button {
                showSpendEditor = true
            } label: {
                HStack {
                    Label("Daily spend", systemImage: "dollarsign.circle")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("$\(Int(store.habitData.dailySpend))/day")
                        .foregroundStyle(Color.accentColor)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            goalRow
            startDateRow
        }
    }

    private var goalRow: some View {
        HStack {
            Label("Goal", systemImage: "target")
            Spacer()
            if editingGoal {
                HStack(spacing: 8) {
                    ForEach([HabitGoal.stopCompletely, .reduceOverTime], id: \.self) { goal in
                        Button(goal == .stopCompletely ? "Stop" : "Reduce") {
                            store.updateGoal(goal)
                            editingGoal = false
                        }
                        .font(.subheadline.weight(.medium))
                        .buttonStyle(.bordered)
                        .tint(store.habitData.goal == goal ? .accentColor : .secondary)
                    }
                }
            } else {
                Button(store.habitData.goal.rawValue) {
                    editingGoal = true
                }
                .foregroundStyle(Color.accentColor)
            }
        }
    }

    private var startDateRow: some View {
        HStack {
            Label("Started", systemImage: "calendar")
            Spacer()
            if editingDate {
                DatePicker("", selection: $editDate, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                Button("Save") {
                    store.updateStartDate(editDate)
                    editingDate = false
                }
                .font(.subheadline.bold())
            } else {
                Button {
                    editDate = store.habitData.startDate
                    editingDate = true
                } label: {
                    Text(store.habitData.startDate, style: .date)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        Section("Reminders") {
            Toggle(isOn: Binding(
                get: { store.habitData.notificationsEnabled },
                set: { store.updateNotifications($0) }
            )) {
                Label("Daily reminder", systemImage: "bell")
            }

            if store.habitData.notificationsEnabled {
                HStack {
                    Label("Time", systemImage: "clock")
                    Spacer()
                    Text("9:00 AM")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Support

    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                SupportView()
            } label: {
                Label("Help & Support", systemImage: "questionmark.circle")
            }
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        Section("Legal") {
            ForEach(LegalPage.allCases, id: \.self) { page in
                NavigationLink(value: page) {
                    Label(page.rawValue, systemImage: page.icon)
                }
            }
        }
    }

    // MARK: - Danger Zone

    private var dangerSection: some View {
        Section {
            Button("Reset progress", role: .destructive) {
                showResetAlert = true
            }
            .alert("Reset your progress?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { store.resetProgress() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset your current run and total days. This can't be undone.")
            }

            Button("Start over completely", role: .destructive) {
                showResetAllAlert = true
            }
            .alert("Start over completely?", isPresented: $showResetAllAlert) {
                Button("Start Over", role: .destructive) { store.resetAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase everything and take you back to setup.")
            }
        }
    }
}

// MARK: - Daily Spend Editor Sheet

struct DailySpendEditorView: View {
    let store: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Double = 0
    @State private var customText: String = ""
    @State private var isCustom: Bool = false

    private let presets: [Double] = [5, 10, 15, 20, 25, 30, 40, 50]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Daily Spend")
                        .font(.title2.bold())
                    Text("How much do you usually spend per day?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    ForEach(presets, id: \.self) { amount in
                        Button {
                            selectedAmount = amount
                            isCustom = false
                            customText = ""
                        } label: {
                            Text("$\(Int(amount))")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(selectedAmount == amount && !isCustom ? Color.accentColor : Color(.tertiarySystemFill))
                                .foregroundStyle(selectedAmount == amount && !isCustom ? .white : .primary)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    Button {
                        withAnimation(.snappy) {
                            isCustom = true
                            selectedAmount = 0
                        }
                    } label: {
                        Text("Custom amount")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isCustom ? Color.accentColor : .secondary)
                    }

                    if isCustom {
                        HStack {
                            Text("$")
                                .font(.title2.bold())
                                .foregroundStyle(.primary.opacity(0.5))
                            TextField("Amount", text: $customText)
                                .font(.title2.bold())
                                .keyboardType(.decimalPad)
                                .onChange(of: customText) { _, newValue in
                                    if let value = Double(newValue), value > 0 {
                                        selectedAmount = value
                                    }
                                }
                        }
                        .padding(16)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                Spacer()

                Button {
                    if selectedAmount > 0 {
                        store.updateDailySpend(selectedAmount)
                    }
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedAmount > 0 ? Color.accentColor : Color(.tertiarySystemFill))
                        .foregroundStyle(selectedAmount > 0 ? .white : .secondary)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .disabled(selectedAmount <= 0)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                selectedAmount = store.habitData.dailySpend
                if !presets.contains(selectedAmount) {
                    isCustom = true
                    customText = "\(Int(selectedAmount))"
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
