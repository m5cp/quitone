import ActivityKit
import SwiftUI
import WidgetKit

struct StreakActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        var currentRunDays: Int
        var totalSaved: Int
        var statusText: String
    }

    var habitName: String
}

struct StreakLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StreakActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.habitName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(context.state.statusText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    if context.state.totalSaved > 0 {
                        Text("$\(context.state.totalSaved) saved")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(1)

                    Text("\(context.state.currentRunDays)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.green)
                }
            }
            .padding(16)
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.habitName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(context.state.statusText)
                            .font(.subheadline.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 1) {
                        Text("DAY")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("\(context.state.currentRunDays)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(.green)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.totalSaved > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text("$\(context.state.totalSaved) saved")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.green)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            } compactTrailing: {
                Text("Day \(context.state.currentRunDays)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
            } minimal: {
                Text("\(context.state.currentRunDays)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.green)
            }
        }
    }
}
