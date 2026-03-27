import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Privacy Policy")
                    .font(.title.bold())

                Group {
                    section(title: "Your Privacy Matters",
                            body: "QuitOne is designed with your privacy as a priority. All of your habit data, progress, and personal settings are stored locally on your device. We do not collect, transmit, or store any personal information on external servers.")

                    section(title: "Data Storage",
                            body: "All data is stored on-device using local storage. No account creation is required to use QuitOne. Your information never leaves your device unless you explicitly choose to export or share it.")

                    section(title: "Analytics & Tracking",
                            body: "QuitOne does not use any third-party analytics, advertising, or tracking SDKs. We do not track your behavior, collect usage metrics, or share data with any third parties.")

                    section(title: "Notifications",
                            body: "If you enable daily reminders, notification scheduling is handled entirely on your device. No notification data is sent to any server.")

                    section(title: "In-App Purchases",
                            body: "Purchases are processed securely through Apple's App Store. QuitOne does not have access to your payment information.")

                    section(title: "Data Deletion",
                            body: "You can delete all your data at any time from the Profile screen using the \"Reset All Data\" option. This permanently removes all stored information from your device.")

                    section(title: "License Agreement",
                            body: "Use of this application is subject to the standard Apple End User License Agreement (EULA).")

                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        HStack {
                            Text("View Apple EULA")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.blue)
                    }

                    section(title: "Contact",
                            body: "If you have any questions about this privacy policy, contact us at m5cp@proton.me.")
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
