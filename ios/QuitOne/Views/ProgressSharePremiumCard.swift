import SwiftUI

struct ProgressSharePremiumCard: View {
    let day: Int
    let moneySavedText: String
    let isPremiumUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Share Your Progress")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Create a social media ready progress card")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if !isPremiumUnlocked {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("Pro")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.12))
                        )
                    }
                }

                ProgressSharePreviewMiniCard(
                    day: day,
                    moneySavedText: moneySavedText
                )
                .overlay {
                    if !isPremiumUnlocked {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.black.opacity(0.15))
                    }
                }

                HStack {
                    Text(isPremiumUnlocked ? "Create Share Card" : "Unlock premium sharing")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(isPremiumUnlocked ? Color.blue : Color.primary)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
