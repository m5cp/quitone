import Foundation

nonisolated enum HabitType: String, Codable, Sendable, CaseIterable {
    case money
    case time
    case identity
}

nonisolated enum GoalType: String, Codable, Sendable {
    case stop = "Stop completely"
    case reduce = "Reduce over time"
}

nonisolated enum FrequencyLevel: String, Codable, Sendable {
    case occasionally = "Occasionally"
    case daily = "Daily"
    case multipleTimesPerDay = "Multiple times per day"
}

nonisolated struct HabitOption: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let type: HabitType
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

nonisolated struct HabitData: Codable, Sendable {
    var habitName: String
    var habitType: HabitType
    var startDate: Date
    var goalType: GoalType
    var dailySpend: Double?
    var dailyTimeMinutes: Int?
    var frequencyLevel: FrequencyLevel?
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
        guard let spend = dailySpend else { return 0 }
        return Double(currentRunDays) * spend
    }

    var totalSaved: Double {
        guard let spend = dailySpend else { return 0 }
        return Double(totalProgressDays) * spend
    }

    var totalTimeReclaimed: Int {
        guard let minutes = dailyTimeMinutes else { return 0 }
        return totalProgressDays * minutes
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
    HabitOption(name: "Smoking", icon: "smoke.fill", type: .money),
    HabitOption(name: "Vaping", icon: "cloud.fill", type: .money),
    HabitOption(name: "Alcohol", icon: "wineglass.fill", type: .money),
    HabitOption(name: "Energy Drinks / Coffee", icon: "cup.and.saucer.fill", type: .money),
    HabitOption(name: "Recreational Drugs", icon: "pills.fill", type: .money),
    HabitOption(name: "Sugar / Junk Food", icon: "birthday.cake.fill", type: .money),
    HabitOption(name: "Online Shopping", icon: "cart.fill", type: .money),
    HabitOption(name: "Takeout / Delivery Food", icon: "takeoutbag.and.cup.and.straw.fill", type: .money),
    HabitOption(name: "Social Media", icon: "iphone.gen3", type: .time),
    HabitOption(name: "Phone Use", icon: "moon.fill", type: .time),
    HabitOption(name: "Gaming", icon: "gamecontroller.fill", type: .time),
    HabitOption(name: "Procrastination", icon: "clock.fill", type: .time),
    HabitOption(name: "Poor Sleep Routine", icon: "bed.double.fill", type: .time),
    HabitOption(name: "Overthinking", icon: "brain.head.profile.fill", type: .identity),
    HabitOption(name: "Negative Self-Talk", icon: "text.bubble.fill", type: .identity),
    HabitOption(name: "People-Pleasing", icon: "person.2.fill", type: .identity),
    HabitOption(name: "Comparing Yourself", icon: "arrow.left.arrow.right", type: .identity),
    HabitOption(name: "Adult Content", icon: "eye.slash.fill", type: .identity),
    HabitOption(name: "Skipping Exercise", icon: "figure.run", type: .identity),
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
    "You're taking back your time.",
    "This is real progress.",
    "Small steps, big change.",
    "You're making a difference.",
    "Every day counts.",
    "You're stronger than you think.",
    "Trust the process.",
    "Progress over perfection.",
]
