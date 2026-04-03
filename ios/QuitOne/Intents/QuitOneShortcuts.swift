import AppIntents

struct QuitOneShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckInIntent(),
            phrases: [
                "Check in on \(.applicationName)",
                "I stayed on track with \(.applicationName)",
                "Log my day on \(.applicationName)",
            ],
            shortTitle: "Check In",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: ViewProgressIntent(),
            phrases: [
                "How am I doing on \(.applicationName)",
                "Show my \(.applicationName) progress",
                "My streak on \(.applicationName)",
            ],
            shortTitle: "View Progress",
            systemImageName: "chart.bar.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .grayGreen
}
