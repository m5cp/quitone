import Foundation
import WidgetKit

nonisolated struct HabitDataAccess: Sendable {
    private static let habitKey = "habitData_v2"
    private static let appGroupID = "group.app.rork.s72ki6xrr9qwpr76nce51"

    static func load() -> HabitData? {
        if let saved = UserDefaults.standard.data(forKey: habitKey),
           let decoded = try? JSONDecoder().decode(HabitData.self, from: saved) {
            return decoded
        }
        return nil
    }

    static func save(_ data: HabitData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: habitKey)
        }
        syncWidget(data)
    }

    static func checkInToday() -> HabitData? {
        guard var data = load() else { return nil }
        let today = HabitData.dateString(from: Date())
        guard !data.completionHistory.contains(where: { $0.dateString == today }) else { return data }
        data.completionHistory.append(DayEntry(dateString: today, status: .completed))
        save(data)
        return data
    }

    private static func syncWidget(_ data: HabitData) {
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

        let widgetData = QuitOneWidgetData(
            habitName: data.habitName,
            currentRunDays: data.currentRunDays,
            moneySaved: data.totalSaved,
            statusText: status,
            lastUpdated: Date()
        )

        let defaults = UserDefaults(suiteName: appGroupID)
        if let encoded = try? JSONEncoder().encode(widgetData) {
            defaults?.set(encoded, forKey: "quitone_widget_data")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
