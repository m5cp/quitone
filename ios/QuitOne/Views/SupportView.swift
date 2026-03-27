import SwiftUI

struct SupportView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("We're here to help")
                        .font(.title3.bold())
                    Text("If you have questions, feedback, or need assistance with your account, please reach out to our support team.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Get in Touch") {
                Link(destination: URL(string: "mailto:m5cp@proton.me")!) {
                    HStack {
                        Label("Email Support", systemImage: "envelope")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Section("Manage Your Subscription") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("To manage or cancel your subscription, go to your device settings:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Open **Settings** on your device", systemImage: "1.circle.fill")
                        Label("Tap your **Apple ID** at the top", systemImage: "2.circle.fill")
                        Label("Select **Subscriptions**", systemImage: "3.circle.fill")
                        Label("Choose **QuitOne** to manage", systemImage: "4.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                }
                .padding(.vertical, 8)
            }

            Section("Enjoying QuitOne?") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your feedback helps us improve and helps others discover QuitOne. If you're finding value in the app, we'd appreciate a review on the App Store.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Link(destination: URL(string: "https://apps.apple.com")!) {
                        HStack {
                            Label("Rate on the App Store", systemImage: "star")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.large)
    }
}
