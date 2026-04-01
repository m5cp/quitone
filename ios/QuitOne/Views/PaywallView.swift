import SwiftUI
import RevenueCat

struct PaywallView: View {
    var storeVM: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var lifetimePackage: Package? {
        storeVM.offerings?.current?.package(identifier: "$rc_lifetime")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 32)
                        .padding(.bottom, 28)

                    featuresSection
                        .padding(.bottom, 28)

                    valuePitchSection
                        .padding(.bottom, 32)

                    purchaseSection
                        .padding(.bottom, 20)

                    footerSection
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { storeVM.error != nil },
                set: { if !$0 { storeVM.error = nil } }
            )) {
                Button("OK") { storeVM.error = nil }
            } message: {
                Text(storeVM.error ?? "")
            }
            .onChange(of: storeVM.isPremium) { _, isPremium in
                if isPremium { dismiss() }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.04, green: 0.06, blue: 0.04), Color(red: 0.02, green: 0.02, blue: 0.03)]
                : [Color(red: 0.95, green: 0.98, blue: 0.95), .white],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 6) {
                Text("QuitOne Lifetime Pro")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text("One investment. A lifetime of savings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "nosign", color: .red, title: "Ad-Free Experience")
            divider
            featureRow(icon: "calendar.badge.clock", color: .blue, title: "Full Journey History & Interactive Calendar")
            divider
            featureRow(icon: "chart.bar.doc.horizontal", color: .orange, title: "Weekly/Monthly Summaries")
            divider
            featureRow(icon: "chart.line.uptrend.xyaxis", color: .purple, title: "Advanced Trends & Insights")
            divider
            featureRow(icon: "doc.text", color: .green, title: "Export Progress (PDF)")
        }
        .padding(.vertical, 4)
        .background(
            colorScheme == .dark
                ? Color(red: 0.10, green: 0.10, blue: 0.12)
                : Color(.secondarySystemGroupedBackground)
        )
        .clipShape(.rect(cornerRadius: 16))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.06))
            .frame(height: 0.5)
            .padding(.leading, 56)
    }

    private func featureRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)

            Text(title)
                .font(.subheadline.weight(.medium))

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.bold())
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var valuePitchSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundStyle(.yellow)

            Text("Quitting a habit saves the average person over $200/month. This Pro upgrade pays for itself in just a few hours.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            colorScheme == .dark
                ? Color.yellow.opacity(0.06)
                : Color.yellow.opacity(0.08)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private var purchaseSection: some View {
        VStack(spacing: 16) {
            if storeVM.isLoading {
                ProgressView()
                    .frame(height: 56)
            } else if let package = lifetimePackage {
                VStack(spacing: 6) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                    Text("One-time purchase")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task { await storeVM.purchase(package: package) }
                } label: {
                    HStack(spacing: 8) {
                        if storeVM.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Unlock Lifetime Access")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.green.gradient)
                    .clipShape(.rect(cornerRadius: 14))
                }
                .disabled(storeVM.isPurchasing)
                .sensoryFeedback(.impact(weight: .medium), trigger: storeVM.isPurchasing)
            } else {
                ContentUnavailableView("Unable to Load", systemImage: "exclamationmark.triangle", description: Text("Please check your connection and try again."))
                    .frame(height: 120)
            }

            Button {
                Task { await storeVM.restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var footerSection: some View {
        HStack(spacing: 4) {
            Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("·")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Link("Privacy Policy", destination: URL(string: "https://www.apple.com/privacy/")!)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
