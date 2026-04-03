import AppIntents
import WidgetKit

struct WidgetCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Widget Check In"
    static var description = IntentDescription("Check in from the widget.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        _ = HabitDataAccess.checkInToday()
        return .result()
    }
}
