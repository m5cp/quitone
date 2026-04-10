import StoreKit
import Foundation

@MainActor
class ReviewManager {
    private let maxLifetimePrompts = 3
    private let cooldownDays = 30
    private let promptCountKey = "reviewPromptCount"
    private let lastPromptDateKey = "lastReviewPromptDate"
    private let promptedMilestonesKey = "reviewPromptedMilestones"

    static let shared = ReviewManager()

    private let triggerMilestones: Set<Int> = [7, 14, 30, 60, 100, 200, 365]

    func checkAndPrompt(streakDays: Int) {
        guard triggerMilestones.contains(streakDays) else { return }
        guard !hasPromptedForMilestone(streakDays) else { return }
        guard promptCount < maxLifetimePrompts else { return }
        guard isCooldownElapsed else { return }

        markPrompted(milestone: streakDays)
        requestReview()
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        UserDefaults.standard.set(promptCount + 1, forKey: promptCountKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastPromptDateKey)

        SKStoreReviewController.requestReview(in: scene)
    }

    private var promptCount: Int {
        UserDefaults.standard.integer(forKey: promptCountKey)
    }

    private var isCooldownElapsed: Bool {
        let lastTimestamp = UserDefaults.standard.double(forKey: lastPromptDateKey)
        guard lastTimestamp > 0 else { return true }
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return daysSince >= cooldownDays
    }

    private func hasPromptedForMilestone(_ milestone: Int) -> Bool {
        let prompted = UserDefaults.standard.array(forKey: promptedMilestonesKey) as? [Int] ?? []
        return prompted.contains(milestone)
    }

    private func markPrompted(milestone: Int) {
        var prompted = UserDefaults.standard.array(forKey: promptedMilestonesKey) as? [Int] ?? []
        prompted.append(milestone)
        UserDefaults.standard.set(prompted, forKey: promptedMilestonesKey)
    }
}
