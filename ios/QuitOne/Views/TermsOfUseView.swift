import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Terms of Use")
                    .font(.title.bold())

                Text("Last updated: April 2025")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Group {
                    termsSection("Acceptance of Terms",
                        "By downloading, installing, or using QuitOne, you agree to be bound by these Terms of Use. If you do not agree, do not use the app.")

                    termsSection("Description of Service",
                        "QuitOne is a personal habit-tracking application designed for entertainment and accountability purposes. The app allows you to track daily check-ins, view streaks and estimated savings, and receive motivational reminders. QuitOne also provides Home Screen widgets, Lock Screen widgets, and Siri Shortcuts for convenient access to your data.")

                    termsSection("Intended Use",
                        "QuitOne is intended for personal, non-commercial use. You agree to use the app only for its intended purpose of tracking personal habits and progress. You must be at least 17 years of age to use this app.")

                    termsSection("Not Professional Advice",
                        "QuitOne does not provide medical, psychological, financial, or any other form of professional advice. The app is not a substitute for professional counseling, therapy, or treatment. All savings calculations and progress metrics are estimates for motivational purposes only.")

                    termsSection("User Data & Privacy",
                        "All habit data is stored locally on your device using App Groups shared storage. Data is shared between the main app, widgets, and Siri Shortcuts entirely on-device. No personal data is transmitted to external servers. See our Privacy Policy for full details.")

                    termsSection("In-App Purchases",
                        "QuitOne offers a Lifetime Pro upgrade as a one-time purchase through the Apple App Store. All purchases are final and processed by Apple. Refund requests must be directed to Apple. Pro features include ad-free experience, full journey history, interactive calendar, weekly/monthly summaries, advanced trends and insights, and PDF export.")

                    termsSection("Subscription Management",
                        "Purchase validation is managed through RevenueCat. You can verify your purchase status within the app. For billing inquiries, contact Apple Support or manage purchases through your device Settings.")

                    termsSection("Widgets & Extensions",
                        "QuitOne provides Home Screen and Lock Screen widgets that display your habit progress. Widget data refreshes periodically according to system schedules and may not always reflect real-time data. Widget availability and behavior are subject to iOS system limitations.")

                    termsSection("Siri & Shortcuts Integration",
                        "QuitOne supports Siri voice commands and the Shortcuts app for hands-free check-ins and progress viewing. Voice interactions are processed by Apple according to their privacy practices. QuitOne is not responsible for Siri's interpretation or availability.")

                    termsSection("Intellectual Property",
                        "QuitOne and all its content, features, and functionality are owned by the developer and are protected by copyright and other intellectual property laws. You may not copy, modify, distribute, or reverse-engineer any part of the app.")

                    termsSection("Limitation of Liability",
                        "QuitOne is provided \"as is\" without warranties of any kind. The developer is not liable for any damages arising from your use of the app, including but not limited to data loss, inaccurate calculations, or reliance on app content for health-related decisions.")

                    termsSection("Termination",
                        "We reserve the right to modify or discontinue the app at any time without notice. Your right to use the app terminates automatically if you violate these terms.")

                    termsSection("Changes to Terms",
                        "We may update these terms from time to time. Continued use of QuitOne after changes constitutes acceptance of the updated terms.")

                    termsSection("Governing Law",
                        "These terms are governed by the laws of the jurisdiction in which the developer operates, without regard to conflict of law principles.")

                    termsSection("Apple EULA",
                        "Use of this application is also subject to the standard Apple End User License Agreement (EULA).")

                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        HStack {
                            Text("View Apple EULA")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundStyle(.blue)
                    }

                    termsSection("Contact",
                        "For questions about these terms, contact us at m5cp@proton.me.")
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func termsSection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
