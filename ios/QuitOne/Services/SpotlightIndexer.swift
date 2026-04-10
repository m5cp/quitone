import CoreSpotlight
import Foundation

struct SpotlightIndexer {
    static func indexHabit(_ data: HabitData) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
        attributeSet.title = "QuitOne — \(data.habitName)"
        attributeSet.contentDescription = "Day \(data.currentRunDays) streak, \(data.totalProgressDays) total days, $\(Int(data.totalSaved)) saved"
        attributeSet.keywords = ["quit", data.habitName.lowercased(), "streak", "progress", "habit"]

        let item = CSSearchableItem(
            uniqueIdentifier: "quitone-habit-\(data.id)",
            domainIdentifier: "com.quitone.habit",
            attributeSet: attributeSet
        )
        item.expirationDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())

        CSSearchableIndex.default().indexSearchableItems([item])
    }

    static func removeAll() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}
