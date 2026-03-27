import SwiftUI
import UserNotifications

@Observable
@MainActor
class HabitStore {
    var habitData: HabitData?
    var hasCompletedOnboarding: Bool = false
    var isPremium: Bool = false

    private let dataKey = "habitData"
    private let onboardingKey = "hasCompletedOnboarding"
    private let premiumKey = "isPremium"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        loadData()
    }

    func completeOnboarding(data: HabitData) {
        habitData = data
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        saveData()
        scheduleNotification()
    }

    func checkInToday() {
        guard var data = habitData else { return }
        let today = HabitData.dateString(from: Date())
        guard !data.completionHistory.contains(where: { $0.dateString == today }) else { return }
        data.completionHistory.append(DayEntry(dateString: today, status: .completed))
        habitData = data
        saveData()
    }

    func slipToday() {
        guard var data = habitData else { return }
        let today = HabitData.dateString(from: Date())
        data.completionHistory.removeAll { $0.dateString == today }
        data.completionHistory.append(DayEntry(dateString: today, status: .slipped))
        habitData = data
        saveData()
    }

    func updateDailySpend(_ amount: Double) {
        guard var data = habitData else { return }
        data.dailySpend = amount
        habitData = data
        saveData()
    }

    func updateDailyTime(_ minutes: Int) {
        guard var data = habitData else { return }
        data.dailyTimeMinutes = minutes
        habitData = data
        saveData()
    }

    func updateStartDate(_ date: Date) {
        guard var data = habitData else { return }
        data.startDate = date
        habitData = data
        saveData()
    }

    func updateGoal(_ goal: GoalType) {
        guard var data = habitData else { return }
        data.goalType = goal
        habitData = data
        saveData()
    }

    func resetAllData() {
        habitData = nil
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: dataKey)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func statusForDate(_ date: Date) -> DayStatus? {
        let dateStr = HabitData.dateString(from: date)
        return habitData?.completionHistory.first { $0.dateString == dateStr }?.status
    }

    func bestRun() -> Int {
        guard let data = habitData else { return 0 }
        let sorted = data.completionHistory
            .filter { $0.status == .completed }
            .compactMap { $0.date }
            .sorted()

        guard !sorted.isEmpty else { return 0 }

        let calendar = Calendar.current
        var best = 1
        var current = 1

        for i in 1..<sorted.count {
            let diff = calendar.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
            if diff == 1 {
                current += 1
                best = max(best, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return max(best, current)
    }

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            Task { @MainActor in
                self.setupDailyNotification()
            }
        }
    }

    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
            if newValue {
                scheduleNotification()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }
    }

    private func setupDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let messages = [
            "Your progress is waiting for you.",
            "Stay on track today.",
            "You're building momentum.",
            "Quick check-in available.",
            "One tap to keep your streak going.",
            "You're doing great — check in today.",
            "A moment for yourself today.",
        ]

        let content = UNMutableNotificationContent()
        content.title = "QuitOne"
        content.body = messages.randomElement() ?? "Check in today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        center.add(request)
    }

    private func saveData() {
        guard let data = habitData else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: dataKey)
        }
    }

    private func loadData() {
        guard let saved = UserDefaults.standard.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(HabitData.self, from: saved) else { return }
        habitData = decoded
    }
}
