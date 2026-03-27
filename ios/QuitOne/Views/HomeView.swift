import SwiftUI

struct HomeView: View {
    let store: HabitStore
    @State private var checkInTrigger: Int = 0
    @State private var showSlipAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                heroCard
                actionButtons
                insightCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.secondarySystemBackground))
        .alert("One day doesn't erase your progress.", isPresented: $showSlipAlert) {
            Button("Keep going") {
                store.checkInSlip()
                checkInTrigger += 1
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You're still building something. Your total progress is preserved.")
        }
        .overlay {
            if store.showSlipMessage {
                slipEncouragement
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store.habitData.habitName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Text(store.statusMessage)
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var heroCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(store.habitData.currentRunDays)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: store.habitData.currentRunDays)
                Text("day current run")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.75))
            }

            HStack(spacing: 0) {
                statColumn(value: "\(store.habitData.totalProgressDays)", label: "Total Days")
                Divider().frame(height: 36)
                savedStatColumn
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
    }

    private var savedStatColumn: some View {
        statColumn(value: store.formattedSaved, label: "Saved")
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                store.checkInOnTrack()
                checkInTrigger += 1
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .symbolEffect(.bounce, value: checkInTrigger)
                    Text("I stayed on track today")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
                .background(store.habitData.hasCheckedInToday ? Color(.systemFill) : Color.accentColor)
                .foregroundStyle(store.habitData.hasCheckedInToday ? Color(.label).opacity(0.5) : Color.white)
                .clipShape(.rect(cornerRadius: 16))
            }
            .disabled(store.habitData.hasCheckedInToday)
            .sensoryFeedback(.success, trigger: checkInTrigger)

            Button {
                showSlipAlert = true
            } label: {
                Text("I had a slip \u{2014} keep going")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
            }
            .disabled(store.habitData.hasCheckedInToday)

            if store.habitData.hasCheckedInToday {
                Label("Checked in today", systemImage: "checkmark")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy, value: store.habitData.hasCheckedInToday)
    }

    private var insightCard: some View {
        Text(store.dailyInsight)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary.opacity(0.8))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var slipEncouragement: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentColor)
                Text("You're still building something.")
                    .font(.headline)
                Text("Start again today.")
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.7))
                Button("Okay") {
                    withAnimation(.smooth) {
                        store.showSlipMessage = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .padding(.top, 4)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 24))
            .padding(.horizontal, 24)
            Spacer()
        }
        .background(.black.opacity(0.2))
        .transition(.opacity)
        .animation(.smooth, value: store.showSlipMessage)
    }
}
