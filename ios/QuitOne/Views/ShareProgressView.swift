import SwiftUI

@MainActor
struct ShareProgressView: View {
    let store: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: ShareCardStyle = .bold
    @State private var showPaywall: Bool = false
    @State private var renderedImage: UIImage?

    private var data: HabitData? { store.habit }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        cardPreview
                            .padding(.top, 16)

                        styleSelector
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                shareButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onChange(of: selectedStyle) { _, _ in
                renderCard()
            }
            .onAppear {
                renderCard()
            }
        }
    }

    private var cardPreview: some View {
        Group {
            if let data {
                ShareCardView(
                    habitName: data.habitName,
                    currentRunDays: data.currentRunDays,
                    totalSaved: data.totalSaved,
                    dailySpend: data.dailySpend,
                    bestStreak: store.bestRun(),
                    style: selectedStyle
                )
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            }
        }
    }

    private var styleSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Style")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ShareCardStyle.allCases) { style in
                        styleButton(style)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private func styleButton(_ style: ShareCardStyle) -> some View {
        Button {
            if style.isPremium && !store.isPremium {
                showPaywall = true
            } else {
                selectedStyle = style
            }
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(thumbnailColor(for: style))
                    .frame(width: 56, height: 56)
                    .overlay {
                        if style.isPremium && !store.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        } else {
                            Text("A")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(thumbnailTextColor(for: style))
                        }
                    }
                    .overlay {
                        if selectedStyle == style {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.green, lineWidth: 2.5)
                        }
                    }

                Text(style.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(selectedStyle == style ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func thumbnailColor(for style: ShareCardStyle) -> Color {
        switch style {
        case .bold: return .white
        case .minimal: return Color(red: 0.97, green: 0.97, blue: 0.96)
        case .dark: return Color(red: 0.08, green: 0.08, blue: 0.08)
        case .gradient: return Color(red: 0.12, green: 0.56, blue: 0.42)
        case .clean: return Color(red: 0.95, green: 0.97, blue: 0.95)
        }
    }

    private func thumbnailTextColor(for style: ShareCardStyle) -> Color {
        switch style {
        case .bold: return .green
        case .minimal: return .black
        case .dark: return .green
        case .gradient: return .white
        case .clean: return .green
        }
    }

    private var shareButton: some View {
        Button {
            shareCard()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                Text("Share")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.green)
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func renderCard() {
        guard let data else { return }
        let cardView = ShareCardView(
            habitName: data.habitName,
            currentRunDays: data.currentRunDays,
            totalSaved: data.totalSaved,
            dailySpend: data.dailySpend,
            bestStreak: store.bestRun(),
            style: selectedStyle
        )

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        renderedImage = renderer.uiImage
    }

    @MainActor
    private func shareCard() {
        renderCard()
        guard let image = renderedImage else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var presentingVC = rootVC
        while let presented = presentingVC.presentedViewController {
            presentingVC = presented
        }
        presentingVC.present(activityVC, animated: true)
    }
}
