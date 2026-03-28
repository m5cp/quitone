import Foundation

nonisolated enum GoalType: String, Codable, Sendable {
    case stop = "Stop completely"
    case reduce = "Reduce over time"
}

nonisolated enum DayStatus: String, Codable, Sendable {
    case completed
    case slipped
}

nonisolated struct SpendRateChange: Codable, Identifiable, Sendable {
    var id: String { dateString }
    let dateString: String
    let dailySpend: Double
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
    var spendRateHistory: [SpendRateChange]
    var completionHistory: [DayEntry]

    nonisolated enum CodingKeys: String, CodingKey {
        case id, habitName, startDate, goalType, dailySpend, spendRateHistory, completionHistory
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        habitName = try container.decode(String.self, forKey: .habitName)
        startDate = try container.decode(Date.self, forKey: .startDate)
        goalType = try container.decode(GoalType.self, forKey: .goalType)
        dailySpend = try container.decode(Double.self, forKey: .dailySpend)
        spendRateHistory = try container.decodeIfPresent([SpendRateChange].self, forKey: .spendRateHistory) ?? []
        completionHistory = try container.decode([DayEntry].self, forKey: .completionHistory)
    }

    init(id: String = UUID().uuidString, habitName: String, startDate: Date, goalType: GoalType, dailySpend: Double, spendRateHistory: [SpendRateChange] = [], completionHistory: [DayEntry] = []) {
        self.id = id
        self.habitName = habitName
        self.startDate = startDate
        self.goalType = goalType
        self.dailySpend = dailySpend
        self.spendRateHistory = spendRateHistory
        self.completionHistory = completionHistory
    }

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
        savedForCompletedDays(completedDays: currentRunCompletedDates)
    }

    var totalSaved: Double {
        let completedDates = completionHistory
            .filter { $0.status == .completed }
            .compactMap { $0.date }
        return savedForCompletedDays(completedDays: completedDates)
    }

    private var currentRunCompletedDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        var checkDate = today

        while true {
            let dateStr = Self.dateString(from: checkDate)
            if let entry = completionHistory.first(where: { $0.dateString == dateStr }) {
                if entry.status == .completed {
                    dates.append(checkDate)
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
        return dates
    }

    func spendRateForDate(_ dateString: String) -> Double {
        let sortedHistory = spendRateHistory.sorted { $0.dateString < $1.dateString }
        var rate = sortedHistory.first?.dailySpend ?? dailySpend
        for change in sortedHistory {
            if change.dateString <= dateString {
                rate = change.dailySpend
            } else {
                break
            }
        }
        return rate
    }

    private func savedForCompletedDays(completedDays: [Date]) -> Double {
        guard !spendRateHistory.isEmpty else {
            return Double(completedDays.count) * dailySpend
        }
        var total: Double = 0
        for date in completedDays {
            let dateStr = Self.dateString(from: date)
            total += spendRateForDate(dateStr)
        }
        return total
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
    "You're proving something to yourself.",
    "This takes courage.",
    "You chose yourself today.",
    "That's another day in the bank.",
    "Quiet strength is still strength.",
    "You're rewriting your story.",
    "Momentum is on your side.",
    "This version of you is powerful.",
    "You didn't quit on yourself.",
    "Look how far you've come.",
    "Every hour matters.",
    "You're investing in your future.",
    "Discipline is freedom.",
    "You're becoming who you want to be.",
    "Slow and steady wins.",
    "Your future self thanks you.",
    "This is what growth looks like.",
    "You're doing the hard thing.",
    "One more day of proof.",
    "You're already different.",
    "Consistency is your superpower.",
    "The best time to start was yesterday. You started.",
    "You're building something real.",
    "This is your turning point.",
    "Strength doesn't always roar.",
    "You showed up again.",
    "That's what commitment looks like.",
    "You're not just trying — you're doing.",
    "The hard part is behind you.",
    "Your effort is paying off.",
    "You're worth this change.",
    "Today was a win.",
    "You're breaking the cycle.",
    "Keep stacking these days.",
    "You're more resilient than you know.",
    "This is you at your best.",
    "Small wins build big changes.",
    "You're creating a new normal.",
    "Don't underestimate your progress.",
    "You're on a roll.",
    "This habit doesn't own you anymore.",
    "Freedom looks good on you.",
    "Your willpower is growing.",
    "You're in control.",
    "Another day, another victory.",
    "You're choosing better.",
    "This is what change feels like.",
    "You're building a life you're proud of.",
    "The streak continues.",
    "You're unstoppable.",
    "Believe in your progress.",
    "You're healing.",
    "Each day gets a little easier.",
    "You're setting an example.",
    "This takes real strength.",
    "You're becoming more free.",
    "Your commitment is inspiring.",
    "Stay the course.",
    "You're doing this for you.",
    "The numbers don't lie — you're winning.",
    "You've earned this progress.",
    "Keep showing up.",
    "You matter, and so does this.",
    "You're putting yourself first.",
    "This is self-respect in action.",
    "You're not looking back.",
    "Forward is the only direction.",
    "You're braver than you feel.",
    "Your consistency speaks volumes.",
    "You're reclaiming your life.",
    "One day closer to the person you want to be.",
    "This is quiet power.",
    "You're making it happen.",
    "Nothing can take this from you.",
    "You've already beaten the hardest day.",
    "You're showing yourself what's possible.",
    "This is a gift to your future.",
    "You deserve to feel proud.",
    "You chose growth today.",
    "Keep going — it's working.",
    "You're writing a new chapter.",
    "The old patterns are fading.",
    "You're replacing habits with freedom.",
    "This is you leveling up.",
    "Your mind is getting stronger.",
    "You're in the driver's seat.",
    "No one can do this for you — and you're doing it.",
    "You're building a better foundation.",
    "Day by day, you're transforming.",
    "This progress is permanent.",
    "You're making space for better things.",
    "Your future is looking brighter.",
    "You're planting seeds of change.",
    "The compound effect is real.",
    "You're outgrowing old habits.",
    "This is what self-care really looks like.",
    "You're choosing clarity.",
    "Your resolve is admirable.",
    "Keep building this momentum.",
    "You're defying expectations.",
    "You're not the same person you were.",
    "Change is happening right now.",
    "You're taking your power back.",
    "Every day is a statement.",
    "You're living with intention.",
    "This is your comeback story.",
    "You're rising above.",
    "The best investment is in yourself.",
    "You're gaining clarity every day.",
    "You're letting go of what held you back.",
    "This journey is yours — own it.",
    "You're demonstrating real courage.",
    "Self-discipline is self-love.",
    "You're building unshakable habits.",
    "Your perseverance is remarkable.",
    "You're winning the mental game.",
    "This streak is just the beginning.",
    "You're discovering your true strength.",
    "The best days are ahead.",
    "You're creating positive momentum.",
    "Your dedication is paying dividends.",
    "You're mastering self-control.",
    "Each day is a new personal record.",
    "You're defying the odds.",
    "This is the power of patience.",
    "You're carving a new path.",
    "Your determination is unmatched.",
    "You're showing the world what's possible.",
    "Inner peace starts with choices like this.",
    "You're choosing health over habit.",
    "This is what resilience looks like.",
    "You're a force of nature.",
    "Your progress is undeniable.",
    "You're breaking free.",
    "Nothing worth having comes easy — and you're doing it.",
    "You're living proof that change is possible.",
    "The chains are falling away.",
    "You're getting lighter every day.",
    "This is empowerment.",
    "You're honoring your word to yourself.",
    "Your future is unwritten — and it's bright.",
    "You're choosing freedom over comfort.",
    "This takes guts. You have them.",
    "You're building a legacy of strength.",
    "The hardest step was the first. You took it.",
    "You're not just surviving — you're thriving.",
    "Your mind is sharper than ever.",
    "You're becoming someone you admire.",
    "Every day clean is a day earned.",
    "You're redefining what's normal for you.",
    "This is your new baseline.",
    "You're raising your own standard.",
    "Your body thanks you.",
    "You're giving yourself the gift of time.",
    "The person you're becoming is incredible.",
    "You're making the invisible visible.",
    "Keep trusting yourself.",
    "You're standing taller every day.",
    "This is pure determination.",
    "You're filling your life with better things.",
    "Your energy is shifting.",
    "You're attracting better outcomes.",
    "This is the definition of self-improvement.",
    "You're proving that willpower is a muscle.",
    "Your courage is contagious.",
    "You're making room for joy.",
    "This is what integrity looks like.",
    "You're building trust with yourself.",
    "Your potential is limitless.",
    "You're walking your own path.",
    "This moment is a milestone.",
    "You're stronger today than yesterday.",
    "The version of you tomorrow will be even stronger.",
    "You're taking life one day at a time.",
    "This is a marathon, and you're crushing it.",
    "You're the author of your own story.",
    "Your grit is showing.",
    "You're building a habit of winning.",
    "This is what focus feels like.",
    "You're choosing peace.",
    "Every saved dollar is a vote for your future.",
    "You're learning what you're truly capable of.",
    "This is you, unchained.",
    "Your persistence will outlast any craving.",
    "You're collecting victories.",
    "This calm is earned.",
    "You're designing a better life.",
    "Your confidence is growing.",
    "You're not just quitting — you're upgrading.",
    "This is what taking charge looks like.",
    "You're making decisions your future self will celebrate.",
    "Steady progress beats sudden change.",
    "You're proof that patience pays off.",
    "Your commitment to yourself is beautiful.",
    "You're choosing long-term over short-term.",
    "This is the sound of progress.",
    "You're growing in ways you can't yet see.",
    "Your clarity is increasing daily.",
    "You're building mental muscle.",
    "This is the power of showing up.",
    "You're creating space for what matters.",
    "Your streak is a badge of honor.",
    "You're silencing the doubts.",
    "This is self-mastery in progress.",
    "You're living with purpose.",
    "Your strength is quiet but mighty.",
    "You're making the right call every day.",
    "This path leads somewhere great.",
    "You're a work of art in progress.",
    "Your focus is laser-sharp.",
    "You're outpacing your old self.",
    "This is the reward of discipline.",
    "You're choosing a life of intention.",
    "Your resolve deepens every day.",
    "You're building something nobody can take away.",
    "This is the start of everything.",
    "You're investing in the most important person — you.",
    "Your transformation is underway.",
    "You're earning your own respect.",
    "This is what alignment feels like.",
    "You're moving in the right direction.",
    "Your habits are becoming your identity.",
    "You're crafting a life of freedom.",
    "This is where change lives — in the daily choices.",
    "You're more capable than any craving.",
    "Your peace of mind is priceless.",
    "You're rewriting the rules.",
    "This takes heart. You have plenty.",
    "You're choosing to evolve.",
    "Your progress whispers — but it's deafening.",
    "You're exactly where you need to be.",
    "This is you, fully in control.",
    "You're stacking days like building blocks.",
    "Your journey inspires.",
    "You're becoming unbreakable.",
    "This is the calm after the storm.",
    "You're proving it to the only person who matters — you.",
    "Your best is yet to come.",
    "You're already winning.",
    "This is what success looks like, one day at a time.",
    "You're a testament to human will.",
    "Your story is changing for the better.",
    "You're making every day count.",
    "This is lasting change.",
    "You're choosing yourself, again and again.",
    "Your progress can't be undone.",
    "You're the strongest you've ever been.",
    "This is the life you deserve.",
    "You're not going back.",
    "Your future is being built right now.",
    "You're a daily reminder that change is real.",
]
