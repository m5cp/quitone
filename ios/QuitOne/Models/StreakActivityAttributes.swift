import ActivityKit
import Foundation

nonisolated struct StreakActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var currentRunDays: Int
        var totalSaved: Int
        var statusText: String
    }

    var habitName: String
}
