import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Privacy Policy")
                    .font(.title.bold())

                Text("Last updated: April 2025")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Group {
                    section(title: "Your Privacy Matters",
                            body: "QuitOne is designed with your privacy as a priority. All of your habit data, progress, and personal settings are stored locally on your device. We do not collect, transmit, or store any personal information on external servers.")

                    section(title: "Data Storage",
                            body: "All data is stored on-device using UserDefaults and App Groups shared storage. No account creation is required to use QuitOne. Your information never leaves your device unless you explicitly choose to export or share it.")

                    section(title: "App Groups & Shared Data",
                            body: "QuitOne uses Apple's App Groups technology to securely share your habit data between the main app, Home Screen widgets, and Siri Shortcuts. This data remains entirely on your device and is never transmitted externally. Shared data includes your habit name, check-in status, streak count, and savings estimate.")

                    section(title: "Widgets",
                            body: "QuitOne offers Home Screen and Lock Screen widgets powered by WidgetKit. Widgets display your current streak, savings, and check-in status. Widget data is refreshed periodically on-device using App Groups. No network requests are made by widgets.")

                    section(title: "Siri & App Intents",
                            body: "QuitOne integrates with Siri and the Shortcuts app through Apple's App Intents framework. You can use Siri to check in, view your progress, or interact with the app hands-free. Siri processes your voice commands on-device or through Apple's servers according to Apple's own privacy policy. QuitOne does not send any additional data to external servers through these integrations.")

                    section(title: "Analytics & Tracking",
                            body: "QuitOne does not use any third-party analytics, advertising, or tracking SDKs. We do not track your behavior, collect usage metrics, or share data with any third parties.")

                    section(title: "Notifications",
                            body: "If you enable daily reminders, notification scheduling is handled entirely on your device. No notification data is sent to any server.")

                    section(title: "In-App Purchases",
                            body: "Purchases are processed securely through Apple's App Store and managed via RevenueCat, a third-party purchase management service. RevenueCat receives anonymized transaction data from Apple to validate and manage your purchase status. QuitOne does not have access to your payment information. For more details, see RevenueCat's privacy policy at revenuecat.com/privacy.")

                    section(title: "Data Export",
                            body: "Pro users may export their progress as a PDF. Exported files are generated locally on your device and shared through the standard iOS share sheet. QuitOne does not retain copies of exported data.")

                    section(title: "Data Deletion",
                            body: "You can delete all your data at any time from the Profile screen using the \"Reset All Data\" option. This permanently removes all stored information from your device, including data shared with widgets and Siri through App Groups.")

                    section(title: "Children's Privacy",
                            body: "QuitOne is not directed at children under the age of 17. We do not knowingly collect personal information from children.")

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

                    section(title: "Changes to This Policy",
                            body: "We may update this privacy policy from time to time. Any changes will be reflected within the app. Continued use of QuitOne after changes constitutes acceptance of the updated policy.")

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
