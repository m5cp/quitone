import Foundation
@preconcurrency import UserNotifications

@Observable
@MainActor
class HabitStore {
    var habitData: HabitData {
        didSet { save() }
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    var showSlipMessage: Bool = false

    private let storageKey = "habitData_v2"

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let data = UserDefaults.standard.data(forKey: "habitData_v2"),
           let decoded = try? JSONDecoder().decode(HabitData.self, from: data) {
            self.habitData = decoded
        } else {
            self.habitData = HabitData()
        }
    }

    func completeOnboarding(
        preset: HabitPreset,
        customName: String,
        goal: HabitGoal,
        dailySpend: Double
    ) {
        let now = Date()
        habitData = HabitData(
            preset: preset,
            customHabitName: customName,
            goal: goal,
            dailySpend: dailySpend,
            startDate: now,
            currentRunStartDate: now,
            totalProgressDays: 0,
            checkIns: [],
            notificationsEnabled: true
        )
        hasCompletedOnboarding = true
        scheduleNotification()
    }

    func checkInOnTrack() {
        guard !habitData.hasCheckedInToday else { return }
        habitData.totalProgressDays += 1
        habitData.checkIns.append(CheckInEntry(onTrack: true))
    }

    func checkInSlip() {
        guard !habitData.hasCheckedInToday else { return }
        habitData.currentRunStartDate = Date()
        habitData.checkIns.append(CheckInEntry(onTrack: false))
        showSlipMessage = true
    }

    func updateDailySpend(_ amount: Double) {
        habitData.dailySpend = amount
    }

    func updateNotifications(_ enabled: Bool) {
        habitData.notificationsEnabled = enabled
        if enabled {
            scheduleNotification()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    func updateStartDate(_ date: Date) {
        habitData.startDate = date
        if date > habitData.currentRunStartDate {
            habitData.currentRunStartDate = date
        }
    }

    func updateGoal(_ goal: HabitGoal) {
        habitData.goal = goal
    }

    func resetProgress() {
        let now = Date()
        habitData.currentRunStartDate = now
        habitData.totalProgressDays = 0
        habitData.checkIns = []
    }

    func resetAll() {
        habitData = HabitData()
        hasCompletedOnboarding = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            center.removeAllPendingNotificationRequests()

            let messages = [
                "Your progress is waiting for you.",
                "Stay on track today.",
                "You're building momentum.",
                "One day at a time.",
                "You're doing well. Check in today.",
                "Quick check-in available.",
                "Keep the streak alive.",
                "You're stronger than yesterday.",
                "Small steps, big change.",
                "Your future self will thank you.",
                "Today matters. You've got this.",
                "Progress looks good on you.",
                "Another day, another win.",
                "You're making real progress."
            ]

            let content = UNMutableNotificationContent()
            content.title = "QuitOne"
            content.body = messages[Int.random(in: 0..<messages.count)]
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Display

    var statusMessage: String {
        if habitData.currentRunDays == 0 && habitData.totalProgressDays == 0 {
            if habitData.hasCheckedInToday {
                return "You're off to a great start."
            }
            return "Today is day one."
        } else if habitData.currentRunDays == 0 {
            if habitData.hasCheckedInToday {
                return "You're building momentum."
            }
            return "Start fresh today."
        } else if habitData.currentRunDays < 3 {
            return "You're building momentum."
        } else {
            return "You're still on track."
        }
    }

    var formattedSaved: String {
        let amount = habitData.totalSaved
        if amount >= 1000 {
            return "$\(Int(amount).formatted())"
        }
        return "$\(Int(amount))"
    }

    var formattedCurrentRunSaved: String {
        let amount = habitData.currentRunSaved
        if amount >= 1000 {
            return "$\(Int(amount).formatted())"
        }
        return "$\(Int(amount))"
    }

    var dailyInsight: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let insights = [
            "You've saved about \(formattedSaved) so far.",
            "That adds up quickly.",
            "You're keeping more of your money.",
            "You're building consistency.",
            "Every day counts.",
            "Progress, not perfection.",
            "This is real progress."
        ]
        return insights[day % insights.count]
    }

    private func save() {
        if let data = try? JSONEncoder().encode(habitData) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
