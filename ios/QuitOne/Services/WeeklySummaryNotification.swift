import Foundation
import UserNotifications

struct WeeklySummaryNotification {
    private static let scheduledKey = "weeklySummaryScheduled"

    static func scheduleIfNeeded(store: HabitStore) {
        guard !UserDefaults.standard.bool(forKey: scheduledKey) else { return }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            Task { @MainActor in
                schedule(store: store)
            }
        }
    }

    @MainActor
    static func schedule(store: HabitStore) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weeklySummary"])

        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Recap"
        content.sound = .default

        let daysOnTrack = store.daysOnTrack(last: 7)
        let saved = store.savedAmount(last: 7)
        let streak = store.habit?.currentRunDays ?? 0

        if saved > 0 {
            content.body = "This week: \(daysOnTrack)/7 days on track, $\(Int(saved)) saved. Streak: \(streak) days. Keep it up!"
        } else {
            content.body = "This week: \(daysOnTrack)/7 days on track. Current streak: \(streak) days. You're building something real."
        }

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklySummary", content: content, trigger: trigger)
        center.add(request)

        UserDefaults.standard.set(true, forKey: scheduledKey)
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weeklySummary"])
        UserDefaults.standard.set(false, forKey: scheduledKey)
    }
}
