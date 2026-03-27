import SwiftUI

struct SupportView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("We're here to help.")
                        .font(.headline)
                    Text("If you have questions, feedback, or need assistance with your account, reach out to our support team.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                Link(destination: URL(string: "mailto:m5cp@proton.me")!) {
                    HStack {
                        Label("Email Support", systemImage: "envelope.fill")
                            .foregroundStyle(.blue)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            } header: {
                Text("Contact")
            } footer: {
                Text("We typically respond within 24–48 hours.")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("If you enjoy QuitOne, we'd love your feedback on the App Store. Your review helps others discover the app and keeps us motivated to improve it.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Leave a Review")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("To manage, cancel, or update your subscription, open your device Settings, tap your name at the top, then select Subscriptions. From there you can view and manage all active subscriptions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Manage Subscription")
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}
