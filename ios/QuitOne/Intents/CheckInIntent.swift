import AppIntents
import WidgetKit

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In"
    static var description = IntentDescription("Mark today as on track in QuitOne.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = HabitDataAccess.load()
        guard data != nil else {
            return .result(dialog: "Open QuitOne to set up your habit first.")
        }

        if data?.hasCheckedInToday == true {
            let days = data?.currentRunDays ?? 0
            return .result(dialog: "Already checked in today! Day \(days) — keep going!")
        }

        let updated = HabitDataAccess.checkInToday()
        let days = updated?.currentRunDays ?? 0
        return .result(dialog: "Checked in! You're on day \(days). Keep it up!")
    }
}
