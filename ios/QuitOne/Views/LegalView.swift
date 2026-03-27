import SwiftUI

enum LegalPage: String, CaseIterable {
    case privacyPolicy = "Privacy Policy"
    case termsOfUse = "Terms of Use"
    case eula = "License Agreement"
    case disclaimer = "Disclaimer"

    var icon: String {
        switch self {
        case .privacyPolicy: return "lock.shield"
        case .termsOfUse: return "doc.text"
        case .eula: return "signature"
        case .disclaimer: return "exclamationmark.triangle"
        }
    }
}

struct LegalView: View {
    let page: LegalPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last updated: March 27, 2026")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.45))

                switch page {
                case .privacyPolicy:
                    privacyPolicyContent
                case .termsOfUse:
                    termsOfUseContent
                case .eula:
                    eulaContent
                case .disclaimer:
                    disclaimerContent
                }
            }
            .padding(20)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(page.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Privacy Policy

    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection("Overview") {
                "QuitOne (\"the App\") is designed with your privacy as a priority. We do not collect, store, transmit, or share any personal information. All data you enter into the App remains on your device."
            }

            legalSection("Data Storage") {
                "All habit tracking data, preferences, and settings are stored locally on your device using on-device storage. No data is sent to external servers, cloud services, or third parties. We do not operate any servers that receive your data."
            }

            legalSection("Data We Do Not Collect") {
                """
                We do not collect:
                • Personal identification information (name, email, phone number)
                • Location data
                • Health or medical data
                • Usage analytics or behavioral data
                • Device identifiers for tracking purposes
                • Financial information
                """
            }

            legalSection("Third-Party Services") {
                "The App does not integrate with any third-party analytics, advertising, or data collection services. No data is shared with third parties."
            }

            legalSection("Notifications") {
                "If you enable daily reminders, notification scheduling is handled entirely on your device through Apple's local notification system. No notification data is transmitted externally."
            }

            legalSection("Data Deletion") {
                "You can delete all your data at any time by using the \"Start over completely\" option in the Profile screen, or by deleting the App from your device. Once deleted, data cannot be recovered."
            }

            legalSection("Children's Privacy") {
                "The App is not directed at children under the age of 13. We do not knowingly collect any information from children."
            }

            legalSection("Changes to This Policy") {
                "We may update this Privacy Policy from time to time. Any changes will be reflected within the App. Continued use of the App after changes constitutes acceptance of the revised policy."
            }

            legalSection("Contact") {
                "If you have questions about this Privacy Policy, please contact us through the App Store listing."
            }
        }
    }

    // MARK: - Terms of Use

    private var termsOfUseContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection("Acceptance of Terms") {
                "By downloading, installing, or using QuitOne (\"the App\"), you agree to be bound by these Terms of Use. If you do not agree to these terms, do not use the App."
            }

            legalSection("Description of Service") {
                "QuitOne is a personal accountability and habit-tracking tool. The App allows you to track daily progress toward a personal goal, view estimated financial savings, and receive optional daily reminders. The App is not a medical device, healthcare application, or therapeutic tool."
            }

            legalSection("Permitted Use") {
                """
                You may use the App for personal, non-commercial purposes. You agree not to:
                • Reverse engineer, decompile, or disassemble the App
                • Use the App for any unlawful purpose
                • Attempt to gain unauthorized access to any part of the App
                • Redistribute or republish the App or its content
                """
            }

            legalSection("User Responsibilities") {
                "You are solely responsible for any data you enter into the App. The estimated financial calculations displayed are based entirely on your input and are approximations only. You acknowledge that these figures are not verified financial records."
            }

            legalSection("No Guarantees") {
                "The App is provided on an \"as is\" and \"as available\" basis. We make no warranties or guarantees regarding the accuracy, reliability, or effectiveness of the App. We do not guarantee any specific outcomes from using the App."
            }

            legalSection("Limitation of Liability") {
                "To the maximum extent permitted by applicable law, the developers of QuitOne shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses resulting from your use of the App."
            }

            legalSection("Intellectual Property") {
                "All content, design, and code within the App are protected by intellectual property laws. You are granted a limited, non-exclusive, non-transferable license to use the App for personal purposes."
            }

            legalSection("Termination") {
                "We reserve the right to modify, suspend, or discontinue the App at any time without notice. You may stop using the App at any time by deleting it from your device."
            }

            legalSection("Governing Law") {
                "These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law principles."
            }

            legalSection("Changes to Terms") {
                "We may update these Terms of Use from time to time. Continued use of the App after changes constitutes acceptance of the updated terms."
            }
        }
    }

    // MARK: - EULA

    private var eulaContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection("End-User License Agreement (EULA)") {
                "This End-User License Agreement (\"Agreement\") is between you and QuitOne (\"Licensor\") and governs your use of the QuitOne application (\"Licensed Application\"). By using the Licensed Application, you agree to be bound by this Agreement and Apple's Standard End-User License Agreement (EULA), available at https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
            }

            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                HStack {
                    Image(systemName: "link")
                    Text("View Apple's Standard EULA")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .font(.subheadline.weight(.medium))
                .padding(14)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
            }

            legalSection("Scope of License") {
                "The Licensor grants you a non-transferable, non-exclusive license to use the Licensed Application on any Apple-branded device that you own or control, as permitted by the Usage Rules set forth in the Apple Media Services Terms and Conditions."
            }

            legalSection("Consent to Use of Data") {
                "The Licensed Application does not collect or transmit any personal data. All data is stored locally on your device. Please refer to the Privacy Policy for more details."
            }

            legalSection("Maintenance and Support") {
                "The Licensor is solely responsible for providing any maintenance and support services with respect to the Licensed Application, as specified in this Agreement or as required under applicable law. Apple has no obligation to furnish any maintenance and support services with respect to the Licensed Application."
            }

            legalSection("Warranty") {
                "The Licensed Application is provided \"as is\" without warranty of any kind. The Licensor disclaims all warranties, express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, and non-infringement. In the event of any failure of the Licensed Application, you may notify Apple, and Apple will refund the purchase price (if any) for the Licensed Application. To the maximum extent permitted by applicable law, Apple has no other warranty obligation with respect to the Licensed Application."
            }

            legalSection("Product Claims") {
                "The Licensor, not Apple, is responsible for addressing any claims relating to the Licensed Application, including but not limited to: product liability claims, any claim that the Licensed Application fails to conform to any applicable legal or regulatory requirement, and claims arising under consumer protection, privacy, or similar legislation."
            }

            legalSection("Intellectual Property") {
                "In the event of any third-party claim that the Licensed Application infringes that third party's intellectual property rights, the Licensor, not Apple, will be solely responsible for the investigation, defense, settlement, and discharge of any such intellectual property infringement claim."
            }

            legalSection("Legal Compliance") {
                "You represent and warrant that you are not located in a country that is subject to a U.S. Government embargo, and that you are not listed on any U.S. Government list of prohibited or restricted parties."
            }

            legalSection("Third-Party Beneficiary") {
                "Apple and Apple's subsidiaries are third-party beneficiaries of this Agreement. Upon your acceptance of this Agreement, Apple will have the right (and will be deemed to have accepted the right) to enforce this Agreement against you as a third-party beneficiary thereof."
            }

            legalSection("Apple's Standard EULA") {
                "This Agreement incorporates Apple's Licensed Application End User License Agreement (\"Standard EULA\") by reference. In the event of any conflict between this Agreement and the Standard EULA, the Standard EULA shall prevail. The Standard EULA is available at https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
            }

            legalSection("Termination") {
                "This license is effective until terminated by you or the Licensor. Your rights under this license will terminate automatically if you fail to comply with any of its terms."
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            legalSection("Important Notice") {
                "Please read this disclaimer carefully before using QuitOne."
            }

            legalSection("Not a Medical or Health Application") {
                "QuitOne is NOT a medical application, health application, therapeutic tool, or clinical treatment program. The App is not designed to diagnose, treat, cure, prevent, or mitigate any disease, condition, disorder, or addiction. The App does not provide medical advice, psychological counseling, or any form of healthcare service."
            }

            legalSection("Not a Substitute for Professional Help") {
                "The App is not a substitute for professional medical advice, diagnosis, or treatment. If you are struggling with substance use, dependency, or any health condition, please consult a qualified healthcare professional, licensed counselor, or appropriate medical provider. Never disregard professional medical advice or delay seeking it because of something you have seen in this App."
            }

            legalSection("Personal Accountability Tool Only") {
                "QuitOne is a personal accountability and progress-tracking tool only. It provides a simple way to track daily habits and view estimated figures based on information you provide. The App is intended to support your personal goals but makes no claims about effectiveness, outcomes, or results."
            }

            legalSection("Financial Estimates") {
                "Any financial figures displayed in the App (such as \"estimated spending avoided\") are rough estimates calculated from the daily spend amount you enter. These figures are not verified, audited, or guaranteed to be accurate. They should not be relied upon for financial planning, tax purposes, or any financial decision-making."
            }

            legalSection("No Guarantee of Results") {
                "Use of this App does not guarantee any specific outcome. Individual results vary. The App is a tool to support your personal journey, but success depends on many factors outside the scope of this application."
            }

            legalSection("Emergency Situations") {
                "If you are in crisis or experiencing a medical emergency, please contact emergency services immediately (call 911 in the United States) or reach out to a crisis helpline. This App is not equipped to handle emergencies."
            }

            legalSection("Assumption of Risk") {
                "By using the App, you acknowledge and agree that you use it at your own risk. The developers of QuitOne shall not be held liable for any decisions you make or actions you take based on information displayed in the App."
            }

            legalSection("Indemnification") {
                "You agree to indemnify and hold harmless the developers of QuitOne from any claims, damages, losses, or expenses arising from your use of the App or your violation of these terms."
            }
        }
    }

    // MARK: - Helper

    private func legalSection(_ title: String, content: () -> String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content())
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
