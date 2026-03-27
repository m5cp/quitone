import SwiftUI

struct ContentView: View {
    @State private var store = HabitStore()
    @State private var selectedTab: Int = 0

    var body: some View {
        if store.hasCompletedOnboarding {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: 0) {
                    HomeView(store: store)
                }
                Tab("Progress", systemImage: "chart.bar.fill", value: 1) {
                    HabitProgressView(store: store)
                }
                Tab("Profile", systemImage: "person.fill", value: 2) {
                    ProfileView(store: store)
                }
            }
            .tint(.green)
        } else {
            OnboardingView(store: store)
        }
    }
}
