import SwiftUI

nonisolated enum CheckInButtonStyle {
    case onTrack
    case slip
}

struct CheckInButton: View {
    let label: String
    let style: CheckInButtonStyle
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                switch style {
                case .onTrack:
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .clipShape(.rect(cornerRadius: 14))
                case .slip:
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
        .buttonStyle(CheckInPressStyle())
    }
}

struct CheckInPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct HomeView: View {
    let store: HabitStore
    @State private var checkInBounce: Int = 0
    @State private var showSlipConfirm: Bool = false
    @State private var insightIndex: Int = 0
    @State private var showShareCard: Bool = false
    @State private var showCheckInConfirmation: Bool = false
    @State private var showSlipConfirmation: Bool = false
    @State private var slipHapticTrigger: Int = 0

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    heroCard
                    actionButtons
                    shareButton
                    insightCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .sensoryFeedback(.success, trigger: checkInBounce)
            .sensoryFeedback(.selection, trigger: slipHapticTrigger)
            .confirmationDialog("Had a slip?", isPresented: $showSlipConfirm, titleVisibility: .visible) {
                Button("Yes, but I'm keeping going") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        store.slipToday()
                        showSlipConfirmation = true
                    }
                    slipHapticTrigger += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSlipConfirmation = false
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("One day doesn't erase your progress. Your total progress is preserved.")
            }
            .onAppear {
                insightIndex = Int.random(in: 0..<insightMessages.count)
            }
            .sheet(isPresented: $showShareCard) {
                ShareProgressView(store: store)
            }
        }
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
            return slipRecoveryMessages[insightIndex % slipRecoveryMessages.count]
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
                            .symbolEffect(.bounce, value: showCheckInConfirmation)
                        Text(showCheckInConfirmation ? "Nice work" : "You're on track today")
                            .font(.headline)
                            .foregroundStyle(.green)
                            .contentTransition(.interpolate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Color.green.opacity(showCheckInConfirmation ? 0.18 : 0.12)
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundStyle(.orange)
                        Text(showSlipConfirmation ? "Tomorrow is yours" : "Tomorrow is a fresh start")
                            .font(.headline)
                            .foregroundStyle(.orange)
                            .contentTransition(.interpolate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 14))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            } else {
                CheckInButton(label: "I stayed on track today", style: .onTrack) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        store.checkInToday()
                        showCheckInConfirmation = true
                    }
                    checkInBounce += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showCheckInConfirmation = false
                        }
                    }
                }

                CheckInButton(label: "I had a slip — keep going", style: .slip) {
                    showSlipConfirm = true
                }
            }
        }
    }

    private var shareButton: some View {
        Button {
            showShareCard = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                Text("Share Progress")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
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
}
