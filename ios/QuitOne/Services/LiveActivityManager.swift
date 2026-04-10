import ActivityKit
import Foundation

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<StreakActivityAttributes>?

    func startOrUpdate(habitName: String, currentRunDays: Int, totalSaved: Int, statusText: String) {
        let state = StreakActivityAttributes.ContentState(
            currentRunDays: currentRunDays,
            totalSaved: totalSaved,
            statusText: statusText
        )

        if let activity = currentActivity, activity.activityState == .active {
            Task {
                await activity.update(.init(state: state, staleDate: nil))
            }
            return
        }

        for activity in Activity<StreakActivityAttributes>.activities {
            if activity.activityState == .active {
                currentActivity = activity
                Task {
                    await activity.update(.init(state: state, staleDate: nil))
                }
                return
            }
        }

        let attributes = StreakActivityAttributes(habitName: habitName)
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // Live Activities may not be available
        }
    }

    func endActivity() {
        Task {
            for activity in Activity<StreakActivityAttributes>.activities {
                let finalState = StreakActivityAttributes.ContentState(
                    currentRunDays: 0,
                    totalSaved: 0,
                    statusText: "Ended"
                )
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            }
            currentActivity = nil
        }
    }

    var isActive: Bool {
        !Activity<StreakActivityAttributes>.activities.filter { $0.activityState == .active }.isEmpty
    }
}
