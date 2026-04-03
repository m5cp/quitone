import WidgetKit
import SwiftUI

nonisolated struct QuitOneWidgetData: Codable, Sendable {
    let habitName: String
    let currentRunDays: Int
    let moneySaved: Double
    let statusText: String
    let lastUpdated: Date
}

nonisolated struct QuitOneEntry: TimelineEntry, Sendable {
    let date: Date
    let habitName: String
    let currentRunDays: Int
    let moneySaved: Double
    let statusText: String
}

nonisolated struct QuitOneProvider: TimelineProvider {
    private let appGroupID = "group.app.rork.s72ki6xrr9qwpr76nce51"

    func placeholder(in context: Context) -> QuitOneEntry {
        QuitOneEntry(date: Date(), habitName: "Smoking", currentRunDays: 21, moneySaved: 84, statusText: "Still on track")
    }

    func getSnapshot(in context: Context, completion: @escaping (QuitOneEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuitOneEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> QuitOneEntry {
        let defaults = UserDefaults(suiteName: appGroupID)

        guard
            let data = defaults?.data(forKey: "quitone_widget_data"),
            let decoded = try? JSONDecoder().decode(QuitOneWidgetData.self, from: data)
        else {
            return QuitOneEntry(date: Date(), habitName: "QuitOne", currentRunDays: 0, moneySaved: 0, statusText: "Open app to start")
        }

        return QuitOneEntry(
            date: Date(),
            habitName: decoded.habitName,
            currentRunDays: decoded.currentRunDays,
            moneySaved: decoded.moneySaved,
            statusText: decoded.statusText
        )
    }
}

struct QuitOneWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuitOneEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            LockRectangularView(entry: entry)
        case .accessoryInline:
            LockInlineView(entry: entry)
        case .accessoryCircular:
            LockCircularView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: QuitOneEntry

    private var savedText: String {
        "$\(Int(entry.moneySaved)) saved"
    }

    private var isCheckedIn: Bool {
        entry.statusText == "Still on track"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.habitName)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))

            Spacer()

            Text("DAY")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.5))

            Text("\(entry.currentRunDays)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)

            Spacer()
                .frame(height: 4)

            if isCheckedIn {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                    Text(savedText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.green)
            } else {
                Text(savedText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.green)

                Text(entry.statusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "quitone://checkin"))
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.15),
                        Color.clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
    }
}

struct MediumWidgetView: View {
    let entry: QuitOneEntry

    private var savedText: String {
        "$\(Int(entry.moneySaved)) saved"
    }

    private var isCheckedIn: Bool {
        entry.statusText == "Still on track"
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.habitName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                if isCheckedIn {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("On track today")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.green)
                } else {
                    Text(entry.statusText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)
                    Text(savedText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("DAY")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.5))

                Text("\(entry.currentRunDays)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
            }
        }
        .widgetURL(URL(string: "quitone://checkin"))
        .containerBackground(for: .widget) {
            ZStack {
                Color.black
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.12),
                        Color.clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
    }
}

struct LockRectangularView: View {
    let entry: QuitOneEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("QuitOne")
                .font(.system(size: 12, weight: .bold))
                .widgetAccentable()

            Text("Day \(entry.currentRunDays) · $\(Int(entry.moneySaved)) saved")
                .font(.system(size: 14, weight: .semibold))

            Text(entry.statusText)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LockInlineView: View {
    let entry: QuitOneEntry

    var body: some View {
        Text("Day \(entry.currentRunDays) · $\(Int(entry.moneySaved)) saved")
    }
}

struct LockCircularView: View {
    let entry: QuitOneEntry

    var body: some View {
        VStack(spacing: 1) {
            Text("DAY")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)

            Text("\(entry.currentRunDays)")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5)
                .widgetAccentable()
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }
}

struct QuitOneWidget: Widget {
    let kind: String = "QuitOneWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuitOneProvider()) { entry in
            QuitOneWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("QuitOne")
        .description("Track your progress at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .containerBackgroundRemovable(false)
    }
}
