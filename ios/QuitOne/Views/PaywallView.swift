import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)

                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange)

                    VStack(spacing: 8) {
                        Text("Upgrade to QuitOne Pro")
                            .font(.title2.bold())
                        Text("Get more from your progress")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "list.bullet.circle.fill", text: "Track multiple habits", color: .green)
                        benefitRow(icon: "calendar.circle.fill", text: "Full history access", color: .blue)
                        benefitRow(icon: "chart.line.uptrend.xyaxis.circle.fill", text: "Deeper insights & trends", color: .orange)
                        benefitRow(icon: "square.and.arrow.up.circle.fill", text: "Export your progress", color: .purple)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))

                    VStack(spacing: 8) {
                        Text("7-day free trial")
                            .font(.headline)
                        Text("then $19.99/year")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Try Free for 7 Days")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.green)
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text("Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func benefitRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
