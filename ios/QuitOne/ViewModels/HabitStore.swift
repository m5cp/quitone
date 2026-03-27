import SwiftUI
import UserNotifications

@Observable
@MainActor
class HabitStore {
    var habits: [HabitData] = []
    var activeHabitId: String?
    var hasCompletedOnboarding: Bool = false
    var isPremium: Bool = false

    private let habitsKey = "habits"
    private let activeHabitIdKey = "activeHabitId"
    private let onboardingKey = "hasCompletedOnboarding"
    private let premiumKey = "isPremium"

    var activeHabit: HabitData? {
        guard let id = activeHabitId else { return habits.first }
        return habits.first { $0.id == id } ?? habits.first
    }

    var activeHabitIndex: Int? {
        guard let id = activeHabitId ?? habits.first?.id else { return nil }
        return habits.firstIndex { $0.id == id }
    }

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        loadData()
        if activeHabitId == nil, let first = habits.first {
            activeHabitId = first.id
        }
    }

    func completeOnboarding(data: HabitData) {
        habits = [data]
        activeHabitId = data.id
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        saveData()
        scheduleNotification()
    }

    func addHabit(data: HabitData) {
        habits.append(data)
        activeHabitId = data.id
        saveData()
    }

    func switchActiveHabit(to id: String) {
        activeHabitId = id
        UserDefaults.standard.set(id, forKey: activeHabitIdKey)
    }

    func deleteHabit(id: String) {
        habits.removeAll { $0.id == id }
        if activeHabitId == id {
            activeHabitId = habits.first?.id
        }
        saveData()
    }

    func checkInToday() {
        guard let idx = activeHabitIndex else { return }
        let today = HabitData.dateString(from: Date())
        guard !habits[idx].completionHistory.contains(where: { $0.dateString == today }) else { return }
        habits[idx].completionHistory.append(DayEntry(dateString: today, status: .completed))
        saveData()
    }

    func slipToday() {
        guard let idx = activeHabitIndex else { return }
        let today = HabitData.dateString(from: Date())
        habits[idx].completionHistory.removeAll { $0.dateString == today }
        habits[idx].completionHistory.append(DayEntry(dateString: today, status: .slipped))
        saveData()
    }

    func updateDailySpend(_ amount: Double) {
        guard let idx = activeHabitIndex else { return }
        habits[idx].dailySpend = amount
        saveData()
    }

    func updateStartDate(_ date: Date) {
        guard let idx = activeHabitIndex else { return }
        habits[idx].startDate = date
        saveData()
    }

    func updateGoal(_ goal: GoalType) {
        guard let idx = activeHabitIndex else { return }
        habits[idx].goalType = goal
        saveData()
    }

    func resetAllData() {
        habits = []
        activeHabitId = nil
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: activeHabitIdKey)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func statusForDate(_ date: Date) -> DayStatus? {
        let dateStr = HabitData.dateString(from: date)
        return activeHabit?.completionHistory.first { $0.dateString == dateStr }?.status
    }

    func bestRun() -> Int {
        guard let data = activeHabit else { return 0 }
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

    func completionRate(last days: Int) -> Double {
        guard let data = activeHabit else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var completed = 0
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateStr = HabitData.dateString(from: date)
            if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                completed += 1
            }
        }
        return days > 0 ? Double(completed) / Double(days) : 0
    }

    func weeklySpendAvoided() -> [Double] {
        guard let data = activeHabit else { return [] }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weeks: [Double] = []
        for w in 0..<4 {
            var total: Double = 0
            for d in 0..<7 {
                let dayOffset = -(w * 7 + d)
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                let dateStr = HabitData.dateString(from: date)
                if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                    total += data.dailySpend
                }
            }
            weeks.insert(total, at: 0)
        }
        return weeks
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
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
        if let id = activeHabitId {
            UserDefaults.standard.set(id, forKey: activeHabitIdKey)
        }
    }

    private func loadData() {
        if let saved = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([HabitData].self, from: saved) {
            habits = decoded
            activeHabitId = UserDefaults.standard.string(forKey: activeHabitIdKey) ?? decoded.first?.id
        } else if let oldData = UserDefaults.standard.data(forKey: "habitData"),
                  let old = try? JSONDecoder().decode(HabitData.self, from: oldData) {
            habits = [old]
            activeHabitId = old.id
            saveData()
            UserDefaults.standard.removeObject(forKey: "habitData")
        }
    }
}
