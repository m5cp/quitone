import SwiftUI

struct ProfileView: View {
    let store: HabitStore
    @State private var showResetAlert: Bool = false
    @State private var showEditSpend: Bool = false
    @State private var showEditDate: Bool = false
    @State private var showPaywall: Bool = false
    @State private var editStartDate: Date = Date()
    @State private var editSpendText: String = ""
    @State private var showCustomSpendField: Bool = false

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            List {
                if let data {
                    habitSection(data: data)
                }
                settingsSection
                supportSection
                dangerSection
            }
            .navigationTitle("Profile")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { store.resetAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all your progress. This cannot be undone.")
            }
            .sheet(isPresented: $showEditSpend) {
                editSpendSheet
            }
            .sheet(isPresented: $showEditDate) {
                editDateSheet
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func habitSection(data: HabitData) -> some View {
        Section {
            HStack {
                Label("Habit", systemImage: "leaf.fill")
                    .foregroundStyle(.green)
                Spacer()
                Text(data.habitName)
                    .foregroundStyle(.secondary)
            }

            Button {
                editSpendText = "\(Int(data.dailySpend))"
                showCustomSpendField = false
                showEditSpend = true
            } label: {
                HStack {
                    Label("Daily Amount", systemImage: "dollarsign.circle.fill")
                        .foregroundStyle(.green)
                    Spacer()
                    Text("$\(Int(data.dailySpend))/day")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .tint(.primary)

            Button {
                editStartDate = data.startDate
                showEditDate = true
            } label: {
                HStack {
                    Label("Start Date", systemImage: "calendar")
                        .foregroundStyle(.blue)
                    Spacer()
                    Text(data.startDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .tint(.primary)

            HStack {
                Label("Goal", systemImage: "target")
                    .foregroundStyle(.orange)
                Spacer()
                Text(data.goalType.rawValue)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Your Habit")
        }
    }

    private var settingsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { store.notificationsEnabled },
                set: { store.notificationsEnabled = $0 }
            )) {
                Label("Daily Reminder", systemImage: "bell.fill")
                    .foregroundStyle(.primary)
            }
            .tint(.green)

            Button {
                showPaywall = true
            } label: {
                HStack {
                    Label("QuitOne Pro", systemImage: "star.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                    if store.isPremium {
                        Text("Active")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    } else {
                        Text("Upgrade")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .tint(.primary)
        } header: {
            Text("Settings")
        }
    }

    private var supportSection: some View {
        Section {
            NavigationLink {
                SupportView()
            } label: {
                Label("Support", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(.blue)
            }

            NavigationLink {
                LegalView()
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
                    .foregroundStyle(.blue)
            }

            NavigationLink {
                DisclaimerView()
            } label: {
                Label("Disclaimer", systemImage: "info.circle.fill")
                    .foregroundStyle(.blue)
            }
        } header: {
            Text("Help")
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("Reset All Data", systemImage: "trash.fill")
            }
        }
    }

    private var editSpendSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Update Daily Amount")
                    .font(.title2.bold())

                VStack(spacing: 10) {
                    ForEach([5, 10, 15, 20, 25, 30], id: \.self) { amount in
                        Button {
                            store.updateDailySpend(Double(amount))
                            showCustomSpendField = false
                            editSpendText = "\(amount)"
                        } label: {
                            HStack {
                                Text("$\(amount) per day")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Int(editSpendText) == amount && !showCustomSpendField ? .white : .primary)
                                Spacer()
                                if Int(editSpendText) == amount && !showCustomSpendField {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(16)
                            .background(Int(editSpendText) == amount && !showCustomSpendField ? Color.green : Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showCustomSpendField = true
                        editSpendText = ""
                    } label: {
                        HStack {
                            Text("Custom amount")
                                .font(.body.weight(.medium))
                                .foregroundStyle(showCustomSpendField ? .white : .primary)
                            Spacer()
                        }
                        .padding(16)
                        .background(showCustomSpendField ? Color.green : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    if showCustomSpendField {
                        HStack {
                            Text("$")
                                .font(.title2.bold())
                            TextField("0", text: $editSpendText)
                                .font(.title2.bold())
                                .keyboardType(.decimalPad)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showEditSpend = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let val = Double(editSpendText), val > 0 {
                            store.updateDailySpend(val)
                        }
                        showEditSpend = false
                    }
                    .disabled(showCustomSpendField && Double(editSpendText) == nil)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var editDateSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Update Start Date")
                    .font(.title2.bold())

                DatePicker("Start Date", selection: $editStartDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.green)

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showEditDate = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateStartDate(editStartDate)
                        showEditDate = false
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
