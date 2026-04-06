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
    @State private var appeared: Bool = false
    @State private var glowPhase: Bool = false

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
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    heroHeader
                    featuresList
                        .padding(.top, 32)
                    planPicker
                        .padding(.top, 32)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 200)
            }
            .scrollIndicators(.hidden)

            bottomCTA
        }
        .background(background)
        .overlay(alignment: .topTrailing) {
            closeButton
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
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .secondary)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial)
                .clipShape(.circle)
        }
        .padding(.top, 16)
        .padding(.trailing, 20)
    }

    private var background: some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.03, green: 0.03, blue: 0.04) : Color(.systemBackground))
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.green.opacity(colorScheme == .dark ? 0.12 : 0.08),
                            Color.green.opacity(0)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 240
                    )
                )
                .frame(width: 480, height: 480)
                .offset(y: -220)
                .scaleEffect(glowPhase ? 1.1 : 0.9)
                .ignoresSafeArea()
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 44)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.green.opacity(0.25),
                                Color.green.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(glowPhase ? 1.15 : 1.0)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green, Color(red: 0.2, green: 0.8, blue: 0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: appeared)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)

            VStack(spacing: 10) {
                Text("Unlock Your\nFull Journey")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text("The tools to stay on track, for good.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
    }

    private var featuresList: some View {
        VStack(spacing: 16) {
            featureItem(
                icon: "nosign",
                gradient: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 0.9, green: 0.2, blue: 0.3)],
                title: "Ad-Free Experience",
                subtitle: "Clean, distraction-free tracking"
            )
            featureItem(
                icon: "calendar",
                gradient: [Color(red: 0.3, green: 0.5, blue: 1.0), Color(red: 0.2, green: 0.4, blue: 0.9)],
                title: "Full Journey History",
                subtitle: "Calendar view & complete timeline"
            )
            featureItem(
                icon: "chart.bar.fill",
                gradient: [Color.orange, Color(red: 1.0, green: 0.55, blue: 0.0)],
                title: "Weekly & Monthly Summaries",
                subtitle: "See trends and patterns"
            )
            featureItem(
                icon: "chart.line.uptrend.xyaxis",
                gradient: [Color.purple, Color(red: 0.6, green: 0.3, blue: 0.9)],
                title: "Advanced Insights",
                subtitle: "Personalized progress analytics"
            )
            featureItem(
                icon: "square.and.arrow.up",
                gradient: [Color.green, Color(red: 0.2, green: 0.75, blue: 0.4)],
                title: "Export Progress",
                subtitle: "Share your journey as PDF"
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private func featureItem(icon: String, gradient: [Color], title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            colorScheme == .dark
                ? Color.white.opacity(0.05)
                : Color(.secondarySystemGroupedBackground)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private var planPicker: some View {
        VStack(spacing: 12) {
            if storeVM.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if storeVM.offerings?.current != nil {
                HStack(spacing: 10) {
                    planTile(
                        tier: .monthly,
                        label: "Monthly",
                        price: monthlyPackage?.storeProduct.localizedPriceString ?? "$1.99",
                        perUnit: "/mo",
                        badge: nil
                    )

                    planTile(
                        tier: .yearly,
                        label: "Yearly",
                        price: yearlyPackage?.storeProduct.localizedPriceString ?? "$9.99",
                        perUnit: "/yr",
                        badge: savingsBadgeText
                    )

                    planTile(
                        tier: .lifetime,
                        label: "Lifetime",
                        price: lifetimePackage?.storeProduct.localizedPriceString ?? "$19.99",
                        perUnit: "",
                        badge: "BEST"
                    )
                }

                if selectedTier == .yearly {
                    Text("Just \(yearlyPerMonthText) — \(savingsBadgeText.lowercased()) vs monthly")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else if selectedTier == .lifetime {
                    Text("One purchase. Yours forever.")
                        .font(.caption)
                        .foregroundStyle(Color.orange)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            } else {
                ContentUnavailableView(
                    "Unable to Load Plans",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Please check your connection and try again.")
                )
                .frame(height: 160)
            }
        }
        .animation(.snappy, value: selectedTier)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private func planTile(tier: PlanTier, label: String, price: String, perUnit: String, badge: String?) -> some View {
        let isSelected = selectedTier == tier

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTier = tier
            }
        } label: {
            VStack(spacing: 8) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            tier == .lifetime
                                ? AnyShapeStyle(Color.orange.gradient)
                                : AnyShapeStyle(Color.green.gradient)
                        )
                        .clipShape(.capsule)
                } else {
                    Text(" ")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.vertical, 3)
                        .opacity(0)
                }

                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? .primary : .secondary)

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .green : .primary)
                    if !perUnit.isEmpty {
                        Text(perUnit)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 4)
            .background(
                isSelected
                    ? (colorScheme == .dark
                        ? Color.green.opacity(0.10)
                        : Color.green.opacity(0.06))
                    : (colorScheme == .dark
                        ? Color.white.opacity(0.04)
                        : Color(.secondarySystemGroupedBackground))
            )
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                            ? Color.green.opacity(0.6)
                            : Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.06),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedTier)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
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
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.78, blue: 0.38),
                            Color(red: 0.16, green: 0.68, blue: 0.30)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: .green.opacity(colorScheme == .dark ? 0.25 : 0.2), radius: 16, y: 6)
            }
            .disabled(storeVM.isPurchasing || selectedPackage == nil)
            .sensoryFeedback(.impact(weight: .medium), trigger: storeVM.isPurchasing)

            HStack(spacing: 16) {
                Button {
                    Task { await storeVM.restore() }
                } label: {
                    Text("Restore Purchases")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Text("·")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Text("·")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Link("Privacy", destination: URL(string: "https://www.apple.com/privacy/")!)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if selectedTier != .lifetime {
                Text("Cancel anytime. No commitment.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(
                    colorScheme == .dark
                        ? Color(red: 0.03, green: 0.03, blue: 0.04)
                        : Color(.systemBackground)
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.08), radius: 20, y: -8)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var purchaseButtonText: String {
        switch selectedTier {
        case .monthly: return "Start Monthly Plan"
        case .yearly: return "Start Yearly Plan"
        case .lifetime: return "Get Lifetime Access"
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
}
