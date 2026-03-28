import Foundation
import WidgetKit

struct WidgetUpdater {
    static let appGroupID = "group.app.rork.s72ki6xrr9qwpr76nce51"
    static let dataKey = "quitone_widget_data"

    static func update(
        habitName: String,
        currentRunDays: Int,
        moneySaved: Double,
        statusText: String
    ) {
        let data = QuitOneWidgetData(
            habitName: habitName,
            currentRunDays: currentRunDays,
            moneySaved: moneySaved,
            statusText: statusText,
            lastUpdated: Date()
        )

        let defaults = UserDefaults(suiteName: appGroupID)
        if let encoded = try? JSONEncoder().encode(data) {
            defaults?.set(encoded, forKey: dataKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

nonisolated struct QuitOneWidgetData: Codable, Sendable {
    let habitName: String
    let currentRunDays: Int
    let moneySaved: Double
    let statusText: String
    let lastUpdated: Date
}
