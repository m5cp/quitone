import SwiftUI

@MainActor
struct ShareProgressView: View {
    let store: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: ShareCardStyle = .bold
    @State private var showPaywall: Bool = false
    @State private var renderedImage: UIImage?

    private var data: HabitData? { store.habit }

    private let previewScale: CGFloat = 0.3

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
                .scaleEffect(previewScale)
                .frame(width: 1080 * previewScale, height: 1920 * previewScale)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
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
                    .fill(
                        LinearGradient(
                            colors: style.backgroundColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay {
                        if style.isPremium && !store.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        } else {
                            Circle()
                                .fill(style.accent.opacity(0.5))
                                .frame(width: 20, height: 20)
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
        renderer.scale = 1.0
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
