import SwiftUI
import RevenueCat

nonisolated enum PlanTier: String, CaseIterable, Sendable {
    case monthly
    case yearly
    case lifetime
}

struct PaywallView: View {
    var storeVM: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTier: PlanTier = .yearly
    @State private var appearAnimation: Bool = false

    private var monthlyPackage: Package? {
        storeVM.offerings?.current?.package(identifier: "$rc_monthly")
    }

    private var yearlyPackage: Package? {
        storeVM.offerings?.current?.package(identifier: "$rc_annual")
    }

    private var lifetimePackage: Package? {
        storeVM.offerings?.current?.package(identifier: "$rc_lifetime")
    }

    private var selectedPackage: Package? {
        switch selectedTier {
        case .monthly: return monthlyPackage
        case .yearly: return yearlyPackage
        case .lifetime: return lifetimePackage
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    featuresSection
                        .padding(.bottom, 24)

                    competitorSection
                        .padding(.bottom, 24)

                    planCardsSection
                        .padding(.bottom, 24)

                    purchaseButton
                        .padding(.bottom, 16)

                    footerSection
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
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
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                    appearAnimation = true
                }
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
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: appearAnimation)
            }

            VStack(spacing: 6) {
                Text("QuitOne Pro")
                    .font(.title.bold())

                Text("Invest in your journey. Save more than you spend.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "nosign", color: .red, title: "Ad-Free Experience")
            divider
            featureRow(icon: "calendar.badge.clock", color: .blue, title: "Full Journey History & Calendar")
            divider
            featureRow(icon: "chart.bar.doc.horizontal", color: .orange, title: "Weekly/Monthly Summaries")
            divider
            featureRow(icon: "chart.line.uptrend.xyaxis", color: .purple, title: "Advanced Trends & Insights")
            divider
            featureRow(icon: "doc.text", color: .green, title: "Export Progress (PDF)")
        }
        .padding(.vertical, 4)
        .background(cardBg)
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
        .padding(.vertical, 13)
    }

    private var competitorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                Text("How QuitOne Compares")
                    .font(.subheadline.weight(.semibold))
            }

            VStack(spacing: 8) {
                competitorRow(name: "Leading Habit Tracker", price: "$6.99/mo", opacity: 0.5)
                competitorRow(name: "Popular Wellness App", price: "$14.99/mo", opacity: 0.35)
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                        Text("QuitOne Pro")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    Text("from $1.99/mo")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.green.opacity(colorScheme == .dark ? 0.12 : 0.08))
                .clipShape(.rect(cornerRadius: 10))
            }

            Text("Up to 75% less than comparable apps")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(cardBg)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func competitorRow(name: String, price: String, opacity: Double) -> some View {
        HStack {
            Text(name)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Text(price)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.primary.opacity(opacity))
                .strikethrough(color: .red.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private var planCardsSection: some View {
        VStack(spacing: 10) {
            if storeVM.isLoading {
                ProgressView()
                    .frame(height: 180)
            } else if storeVM.offerings?.current != nil {
                planCard(
                    tier: .monthly,
                    title: "Monthly",
                    price: monthlyPackage?.storeProduct.localizedPriceString ?? "$1.99",
                    subtitle: "per month",
                    badge: nil
                )

                planCard(
                    tier: .yearly,
                    title: "Yearly",
                    price: yearlyPackage?.storeProduct.localizedPriceString ?? "$9.99",
                    subtitle: yearlyPerMonthText,
                    badge: savingsBadgeText
                )

                planCard(
                    tier: .lifetime,
                    title: "Lifetime",
                    price: lifetimePackage?.storeProduct.localizedPriceString ?? "$19.99",
                    subtitle: "one-time purchase",
                    badge: "BEST VALUE"
                )
            } else {
                ContentUnavailableView(
                    "Unable to Load Plans",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Please check your connection and try again.")
                )
                .frame(height: 160)
            }
        }
    }

    private var yearlyPerMonthText: String {
        if let product = yearlyPackage?.storeProduct {
            let yearlyPrice = product.price as Decimal
            let monthly = yearlyPrice / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatter?.locale ?? .current
            formatter.maximumFractionDigits = 2
            if let formatted = formatter.string(from: monthly as NSDecimalNumber) {
                return "\(formatted)/mo"
            }
        }
        return "$0.83/mo"
    }

    private var savingsBadgeText: String {
        if let monthlyProduct = monthlyPackage?.storeProduct,
           let yearlyProduct = yearlyPackage?.storeProduct {
            let monthlyAnnual = monthlyProduct.price as Decimal * 12
            let yearlyPrice = yearlyProduct.price as Decimal
            guard monthlyAnnual > 0 else { return "SAVE 58%" }
            let savings = ((monthlyAnnual - yearlyPrice) / monthlyAnnual) * 100
            return "SAVE \(Int(truncating: savings as NSDecimalNumber))%"
        }
        return "SAVE 58%"
    }

    private func planCard(tier: PlanTier, title: String, price: String, subtitle: String, badge: String?) -> some View {
        let isSelected = selectedTier == tier

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTier = tier
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.green : Color.primary.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(
                                    tier == .lifetime
                                        ? Color.orange.gradient
                                        : Color.green.gradient
                                )
                                .clipShape(.capsule)
                        }
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? .green : .primary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                isSelected
                    ? Color.green.opacity(colorScheme == .dark ? 0.10 : 0.06)
                    : cardBg
            )
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.green.opacity(0.5) : Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.06),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedTier)
    }

    private var purchaseButton: some View {
        VStack(spacing: 14) {
            Button {
                guard let package = selectedPackage else { return }
                Task { await storeVM.purchase(package: package) }
            } label: {
                HStack(spacing: 8) {
                    if storeVM.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(purchaseButtonText)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.green.gradient)
                .clipShape(.rect(cornerRadius: 14))
                .shadow(color: .green.opacity(colorScheme == .dark ? 0.2 : 0.15), radius: 12, y: 4)
            }
            .disabled(storeVM.isPurchasing || selectedPackage == nil)
            .sensoryFeedback(.impact(weight: .medium), trigger: storeVM.isPurchasing)

            Button {
                Task { await storeVM.restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var purchaseButtonText: String {
        switch selectedTier {
        case .monthly: return "Start Monthly Plan"
        case .yearly: return "Start Yearly Plan"
        case .lifetime: return "Unlock Lifetime Access"
        }
    }

    private var footerSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundStyle(.yellow)

                Text("Quitting a habit saves the average person over $200/month. This upgrade pays for itself in hours.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(
                colorScheme == .dark
                    ? Color.yellow.opacity(0.06)
                    : Color.yellow.opacity(0.08)
            )
            .clipShape(.rect(cornerRadius: 12))

            VStack(spacing: 4) {
                if selectedTier != .lifetime {
                    Text("Cancel anytime. No commitment.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

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
    }

    private var cardBg: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.10, blue: 0.12)
            : Color(.secondarySystemGroupedBackground)
    }
}
