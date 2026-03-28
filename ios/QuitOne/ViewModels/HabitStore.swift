import SwiftUI
import UserNotifications
import WidgetKit

@Observable
@MainActor
class HabitStore {
    var habit: HabitData?
    var hasCompletedOnboarding: Bool = false
    var isPremium: Bool = false

    private let habitKey = "habitData_v2"
    private let onboardingKey = "hasCompletedOnboarding"
    private let premiumKey = "isPremium"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        loadData()
    }

    func completeOnboarding(data: HabitData) {
        habit = data
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        saveData()
        scheduleNotification()
    }

    func checkInToday() {
        guard habit != nil else { return }
        let today = HabitData.dateString(from: Date())
        guard !(habit!.completionHistory.contains(where: { $0.dateString == today })) else { return }
        habit!.completionHistory.append(DayEntry(dateString: today, status: .completed))
        saveData()
    }

    func slipToday() {
        guard habit != nil else { return }
        let today = HabitData.dateString(from: Date())
        habit!.completionHistory.removeAll { $0.dateString == today }
        habit!.completionHistory.append(DayEntry(dateString: today, status: .slipped))
        saveData()
    }

    func updateDailySpend(_ amount: Double) {
        guard habit != nil else { return }
        let todayStr = HabitData.dateString(from: Date())
        habit!.spendRateHistory.removeAll { $0.dateString == todayStr }
        habit!.spendRateHistory.append(SpendRateChange(dateString: todayStr, dailySpend: amount))
        habit!.dailySpend = amount
        saveData()
    }

    func updateStartDate(_ date: Date) {
        guard habit != nil else { return }
        habit!.startDate = date
        saveData()
    }

    func updateHabitName(_ name: String) {
        guard habit != nil else { return }
        habit!.habitName = name
        saveData()
    }

    func updateGoal(_ goal: GoalType) {
        guard habit != nil else { return }
        habit!.goalType = goal
        saveData()
    }

    func resetAllData() {
        habit = nil
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: habitKey)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func statusForDate(_ date: Date) -> DayStatus? {
        let dateStr = HabitData.dateString(from: date)
        return habit?.completionHistory.first { $0.dateString == dateStr }?.status
    }

    func bestRun() -> Int {
        guard let data = habit else { return 0 }
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
        guard let data = habit else { return 0 }
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

    func daysOnTrack(last days: Int) -> Int {
        guard let data = habit else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateStr = HabitData.dateString(from: date)
            if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                count += 1
            }
        }
        return count
    }

    func savedAmount(last days: Int) -> Double {
        guard let data = habit else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total: Double = 0
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateStr = HabitData.dateString(from: date)
            if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                total += data.spendRateForDate(dateStr)
            }
        }
        return total
    }

    func previousPeriodDaysOnTrack(last days: Int) -> Int {
        guard let data = habit else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        for i in days..<(days * 2) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateStr = HabitData.dateString(from: date)
            if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                count += 1
            }
        }
        return count
    }

    func longestStreak(last days: Int) -> Int {
        guard let data = habit else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var best = 0
        var current = 0

        for i in stride(from: days - 1, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateStr = HabitData.dateString(from: date)
            if data.completionHistory.first(where: { $0.dateString == dateStr })?.status == .completed {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }
        return best
    }

    func nextMilestone() -> Int? {
        guard let data = habit else { return nil }
        let run = data.currentRunDays
        let milestones = [7, 30, 60, 100, 200, 365]
        return milestones.first { $0 > run }
    }

    func daysSinceStart() -> Int {
        guard let data = habit else { return 0 }
        return max(1, Calendar.current.dateComponents([.day], from: data.startDate, to: Date()).day ?? 0)
    }

    func exportProgressText() -> String {
        guard let data = habit else { return "" }
        var lines: [String] = []
        lines.append("QuitOne Progress Export")
        lines.append("Habit: \(data.habitName)")
        lines.append("Start Date: \(data.startDate.formatted(date: .long, time: .omitted))")
        lines.append("Current Run: \(data.currentRunDays) days")
        lines.append("Total Progress: \(data.totalProgressDays) days")
        lines.append("Estimated Saved: $\(Int(data.totalSaved))")
        lines.append("Best Streak: \(bestRun()) days")
        lines.append("")
        lines.append("Daily Log:")
        let sorted = data.completionHistory.sorted { $0.dateString < $1.dateString }
        for entry in sorted {
            let symbol = entry.status == .completed ? "✓" : "✗"
            lines.append("\(entry.dateString): \(symbol)")
        }
        return lines.joined(separator: "\n")
    }

    var habitNameHidden: Bool {
        get { UserDefaults.standard.bool(forKey: "habitNameHidden") }
        set { UserDefaults.standard.set(newValue, forKey: "habitNameHidden") }
    }

    var displayHabitName: String {
        guard let data = habit else { return "Your Habit" }
        return habitNameHidden ? "•••••" : data.habitName
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

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            Task { @MainActor in
                self.setupDailyNotification()
            }
        }
    }

    private func setupDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let messages = GentleReminders.all

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

    func syncWidget() {
        guard let data = habit else { return }
        let status: String
        if data.todayStatus == .slipped {
            status = "Fresh start tomorrow"
        } else if data.hasCheckedInToday {
            status = "Still on track"
        } else if data.currentRunDays > 0 {
            status = "Check in today"
        } else {
            status = "Start today"
        }
        WidgetUpdater.update(
            habitName: data.habitName,
            currentRunDays: data.currentRunDays,
            moneySaved: data.totalSaved,
            statusText: status
        )
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(habit) {
            UserDefaults.standard.set(encoded, forKey: habitKey)
        }
        syncWidget()
    }

    private func loadData() {
        if let saved = UserDefaults.standard.data(forKey: habitKey),
           let decoded = try? JSONDecoder().decode(HabitData.self, from: saved) {
            habit = decoded
        } else if let oldData = UserDefaults.standard.data(forKey: "habits"),
                  let oldList = try? JSONDecoder().decode([HabitData].self, from: oldData),
                  let first = oldList.first {
            habit = first
            saveData()
        } else if let oldData = UserDefaults.standard.data(forKey: "habitData"),
                  let old = try? JSONDecoder().decode(HabitData.self, from: oldData) {
            habit = old
            saveData()
        }
    }
}
