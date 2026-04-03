import AppIntents

struct ViewProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "View Progress"
    static var description = IntentDescription("See your current QuitOne streak and savings.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let data = HabitDataAccess.load() else {
            return .result(dialog: "Open QuitOne to start tracking your habit.")
        }

        let days = data.currentRunDays
        let total = data.totalProgressDays
        let saved = Int(data.totalSaved)

        if saved > 0 {
            return .result(dialog: "Day \(days) current streak, \(total) total days on track, $\(saved) saved.")
        } else {
            return .result(dialog: "Day \(days) current streak, \(total) total days on track.")
        }
    }
}
