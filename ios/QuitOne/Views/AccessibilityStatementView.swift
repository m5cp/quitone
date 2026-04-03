import SwiftUI

struct AccessibilityStatementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Accessibility")
                    .font(.title.bold())

                Text("Last updated: April 2025")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Group {
                    accessibilitySection("Our Commitment",
                        "QuitOne is committed to providing an accessible experience for all users. We strive to follow Apple's accessibility best practices and the Web Content Accessibility Guidelines (WCAG) to ensure everyone can track their progress and celebrate their journey.")

                    accessibilitySection("Dynamic Type",
                        "QuitOne fully supports Dynamic Type across all screens. Text scales according to your preferred reading size set in iOS Settings > Display & Brightness > Text Size. All key metrics, labels, and content adapt to your chosen size for comfortable reading.")

                    accessibilitySection("VoiceOver",
                        "QuitOne is designed to work with VoiceOver, Apple's built-in screen reader. All interactive elements, buttons, progress metrics, and navigation items include descriptive accessibility labels so you can navigate and use the app entirely through VoiceOver.")

                    accessibilitySection("Color & Contrast",
                        "The app uses high-contrast text and semantic system colors that adapt to both Light and Dark Mode. Key information is never conveyed by color alone — icons, labels, and shapes reinforce meaning throughout the interface.")

                    accessibilitySection("Dark Mode",
                        "QuitOne fully supports iOS Dark Mode. You can choose between System, Light, or Dark appearance in the Profile settings. All screens, widgets, and components adapt seamlessly to your chosen appearance.")

                    accessibilitySection("Reduce Motion",
                        "QuitOne respects the Reduce Motion accessibility setting. When enabled, animations are minimized or removed to provide a comfortable experience for users sensitive to motion.")

                    accessibilitySection("Touch Targets",
                        "All interactive elements meet Apple's recommended minimum touch target size of 44×44 points, ensuring buttons, toggles, and tappable areas are easy to interact with regardless of motor ability.")

                    accessibilitySection("Siri & Voice Control",
                        "QuitOne supports Siri Shortcuts, allowing you to check in and view your progress using voice commands. The app is also compatible with iOS Voice Control for hands-free navigation.")

                    accessibilitySection("Widgets",
                        "Home Screen and Lock Screen widgets provide at-a-glance progress information with clear typography and sufficient contrast, accessible without opening the app.")

                    accessibilitySection("Haptic Feedback",
                        "QuitOne uses haptic feedback to reinforce check-in actions and key interactions. Haptics follow system settings and can be adjusted through your device's accessibility preferences.")

                    accessibilitySection("Feedback",
                        "We are continuously working to improve the accessibility of QuitOne. If you encounter any accessibility barriers or have suggestions for improvement, please contact us at m5cp@proton.me. Your feedback helps us make the app better for everyone.")
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func accessibilitySection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
