import Foundation

nonisolated enum GoalType: String, Codable, Sendable {
    case stop = "Stop completely"
    case reduce = "Reduce over time"
}

nonisolated enum DayStatus: String, Codable, Sendable {
    case completed
    case slipped
}

nonisolated struct DayEntry: Codable, Identifiable, Sendable {
    var id: String { dateString }
    let dateString: String
    let status: DayStatus

    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

nonisolated struct HabitOption: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
}

nonisolated struct HabitData: Codable, Identifiable, Sendable {
    var id: String = UUID().uuidString
    var habitName: String
    var startDate: Date
    var goalType: GoalType
    var dailySpend: Double
    var completionHistory: [DayEntry]

    var currentRunDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        var checkDate = today

        while true {
            let dateStr = Self.dateString(from: checkDate)
            if let entry = completionHistory.first(where: { $0.dateString == dateStr }) {
                if entry.status == .completed {
                    count += 1
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = prev
                } else {
                    break
                }
            } else {
                if checkDate == today {
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = prev
                } else {
                    break
                }
            }
        }
        return count
    }

    var totalProgressDays: Int {
        completionHistory.filter { $0.status == .completed }.count
    }

    var currentRunSaved: Double {
        Double(currentRunDays) * dailySpend
    }

    var totalSaved: Double {
        Double(totalProgressDays) * dailySpend
    }

    var hasCheckedInToday: Bool {
        let today = Self.dateString(from: Date())
        return completionHistory.contains { $0.dateString == today }
    }

    var todayStatus: DayStatus? {
        let today = Self.dateString(from: Date())
        return completionHistory.first { $0.dateString == today }?.status
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

let allHabitOptions: [HabitOption] = [
    HabitOption(name: "Smoking", icon: "smoke.fill"),
    HabitOption(name: "Vaping", icon: "cloud.fill"),
    HabitOption(name: "Alcohol", icon: "wineglass.fill"),
    HabitOption(name: "Energy Drinks / Coffee", icon: "cup.and.saucer.fill"),
    HabitOption(name: "Recreational Drugs", icon: "pills.fill"),
    HabitOption(name: "Sugar / Junk Food", icon: "birthday.cake.fill"),
    HabitOption(name: "Online Shopping", icon: "cart.fill"),
    HabitOption(name: "Takeout / Delivery", icon: "takeoutbag.and.cup.and.straw.fill"),
]

let onTrackMessages: [String] = [
    "You're still on track.",
    "You're doing well.",
    "You're building momentum.",
    "Keep it going.",
    "One day at a time.",
    "You've got this.",
    "Strong and steady.",
]

let slipRecoveryMessages: [String] = [
    "One day doesn't erase your progress.",
    "You're still building something.",
    "Start again today.",
    "Progress isn't perfection.",
    "Every day is a fresh start.",
]

let insightMessages: [String] = [
    "You're building consistency.",
    "That adds up quickly.",
    "This is real progress.",
    "Small steps, big change.",
    "You're making a difference.",
    "Every day counts.",
    "You're stronger than you think.",
    "Trust the process.",
    "Progress over perfection.",
]
