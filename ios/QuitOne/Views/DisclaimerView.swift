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

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Entertainment & Accountability")
                    Text("QuitOne is designed for entertainment and personal accountability purposes only. It provides a simple way to track daily habits and visualize your progress over time.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Not Medical or Professional Advice")
                    Text("This app does not provide medical advice, diagnosis, or treatment. QuitOne is not a substitute for professional medical advice, counseling, therapy, or any other form of professional health service.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Seek Professional Help")
                    Text("If you are struggling with substance use, addiction, or any health-related concern, please consult a qualified healthcare professional. In case of emergency, contact your local emergency services immediately.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Estimates & Calculations")
                    Text("All monetary savings and progress calculations displayed within the app are estimates based on the information you provide. They are intended for motivational purposes and may not reflect actual financial savings.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Your Privacy")
                    Text("All data is stored locally on your device. QuitOne does not collect, transmit, or share your personal information with any third parties.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

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

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
    }
}
