import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About QuitOne")
                        .font(.title2.bold())
                    Text("Please read this information carefully before using the app.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                disclaimerSection("Entertainment & Accountability",
                    "QuitOne is designed for entertainment and personal accountability purposes only. It provides a simple way to track daily habits and visualize your progress over time.")

                disclaimerSection("Not Medical or Professional Advice",
                    "This app does not provide medical advice, diagnosis, or treatment. QuitOne is not a substitute for professional medical advice, counseling, therapy, or any other form of professional health service.")

                disclaimerSection("Seek Professional Help",
                    "If you are struggling with substance use, addiction, or any health-related concern, please consult a qualified healthcare professional. In case of emergency, contact your local emergency services immediately.")

                disclaimerSection("Estimates & Calculations",
                    "All monetary savings, progress calculations, and statistics displayed within the app — including those shown in widgets, Siri responses, and exported PDFs — are estimates based on the information you provide. They are intended for motivational purposes and may not reflect actual financial savings.")

                disclaimerSection("Widgets & Siri Integration",
                    "QuitOne provides Home Screen widgets and Siri Shortcuts for convenient access to your progress. Data displayed in widgets and Siri responses is derived from the same on-device data used in the main app. Widget information may be slightly delayed due to system refresh schedules. Siri voice commands are processed according to Apple's privacy practices.")

                disclaimerSection("Data Sharing Between App Components",
                    "QuitOne uses Apple's App Groups to share your habit data between the main app, widgets, and Siri Shortcuts. This sharing occurs entirely on your device and does not involve any external servers or third parties.")

                disclaimerSection("Your Privacy",
                    "All data is stored locally on your device. QuitOne does not collect, transmit, or share your personal information with any third parties. See our Privacy Policy for full details.")

                disclaimerSection("Exported Content",
                    "Progress data exported as PDF is generated on your device. Once shared via the iOS share sheet, QuitOne has no control over how the exported content is used or stored by the receiving app or service.")

                disclaimerSection("Service Availability",
                    "QuitOne is provided as-is. We do not guarantee uninterrupted availability, and the app may be updated or discontinued at any time. In-app purchase features are subject to availability through the Apple App Store.")

                Text("By using QuitOne, you acknowledge and agree that the app is provided as-is for personal accountability and entertainment, and that you will not rely on it as a substitute for professional guidance.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func disclaimerSection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
