import Foundation

nonisolated enum HabitPreset: String, Codable, CaseIterable, Sendable, Identifiable {
    case smoking = "Smoking"
    case vaping = "Vaping"
    case alcohol = "Alcohol"
    case energyDrinks = "Energy Drinks / Coffee"
    case recreationalDrugs = "Recreational Drugs"
    case sugarJunkFood = "Sugar / Junk Food"
    case onlineShopping = "Online Shopping"
    case takeoutDelivery = "Takeout / Delivery Food"
    case custom = "Custom Habit"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .smoking: "lungs"
        case .vaping: "cloud"
        case .alcohol: "wineglass"
        case .energyDrinks: "cup.and.saucer"
        case .recreationalDrugs: "pills"
        case .sugarJunkFood: "fork.knife"
        case .onlineShopping: "cart"
        case .takeoutDelivery: "bag"
        case .custom: "pencil"
        }
    }

    var displayName: String { rawValue }

    static var allHabits: [HabitPreset] {
        [.smoking, .vaping, .alcohol, .energyDrinks, .recreationalDrugs,
         .sugarJunkFood, .onlineShopping, .takeoutDelivery]
    }
}

nonisolated enum HabitGoal: String, Codable, Sendable {
    case stopCompletely = "Stop completely"
    case reduceOverTime = "Reduce over time"
}

nonisolated struct CheckInEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let onTrack: Bool

    init(id: UUID = UUID(), date: Date = Date(), onTrack: Bool) {
        self.id = id
        self.date = date
        self.onTrack = onTrack
    }
}

nonisolated struct HabitData: Codable, Sendable {
    var preset: HabitPreset
    var customHabitName: String
    var goal: HabitGoal
    var dailySpend: Double
    var startDate: Date
    var currentRunStartDate: Date
    var totalProgressDays: Int
    var checkIns: [CheckInEntry]
    var notificationsEnabled: Bool

    var habitName: String {
        preset == .custom ? customHabitName : preset.displayName
    }

    var currentRunDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: currentRunStartDate, to: Date()).day ?? 0)
    }

    var currentRunSaved: Double {
        Double(currentRunDays) * dailySpend
    }

    var totalSaved: Double {
        Double(totalProgressDays) * dailySpend
    }

    var lastCheckInDate: Date? {
        checkIns.last?.date
    }

    var hasCheckedInToday: Bool {
        guard let last = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    init(
        preset: HabitPreset = .smoking,
        customHabitName: String = "",
        goal: HabitGoal = .stopCompletely,
        dailySpend: Double = 10,
        startDate: Date = Date(),
        currentRunStartDate: Date = Date(),
        totalProgressDays: Int = 0,
        checkIns: [CheckInEntry] = [],
        notificationsEnabled: Bool = true
    ) {
        self.preset = preset
        self.customHabitName = customHabitName
        self.goal = goal
        self.dailySpend = dailySpend
        self.startDate = startDate
        self.currentRunStartDate = currentRunStartDate
        self.totalProgressDays = totalProgressDays
        self.checkIns = checkIns
        self.notificationsEnabled = notificationsEnabled
    }
}
