import SwiftUI
import RevenueCat

nonisolated enum QuitOneTab: Int, CaseIterable, Sendable {
    case home = 0
    case progress = 1
    case profile = 2

    var title: String {
        switch self {
        case .home: return "Home"
        case .progress: return "Progress"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .progress: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}

struct ContentView: View {
    @State private var store = HabitStore()
    @State private var storeVM = StoreViewModel()
    @State private var selectedTab: QuitOneTab = .home
    @AppStorage("appearanceMode") private var appearanceMode: Int = 0

    private var resolvedColorScheme: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        if store.hasCompletedOnboarding {
            TabView(selection: $selectedTab) {
                HomeView(store: store, storeVM: storeVM)
                    .tag(QuitOneTab.home)
                    .tabItem {
                        Image(systemName: QuitOneTab.home.icon)
                        Text(QuitOneTab.home.title)
                    }

                HabitProgressView(store: store, storeVM: storeVM)
                    .tag(QuitOneTab.progress)
                    .tabItem {
                        Image(systemName: QuitOneTab.progress.icon)
                        Text(QuitOneTab.progress.title)
                    }

                ProfileView(store: store, storeVM: storeVM)
                    .tag(QuitOneTab.profile)
                    .tabItem {
                        Image(systemName: QuitOneTab.profile.icon)
                        Text(QuitOneTab.profile.title)
                    }
            }
            .tint(.green)
            .onAppear {
                store.syncWidget()
            }
            .onChange(of: storeVM.isPremium) { _, newValue in
                store.isPremium = newValue
            }
            .preferredColorScheme(resolvedColorScheme)
        } else {
            OnboardingView(store: store)
                .preferredColorScheme(resolvedColorScheme)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: QuitOneTab
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(QuitOneTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                            .symbolEffect(.bounce.down, value: selectedTab == tab)

                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? .green : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 2)
                }
            }
        }
        .padding(.bottom, 20)
        .background {
            Rectangle()
                .fill(tabBackground)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08))
                        .frame(height: 0.5)
                }
                .ignoresSafeArea()
        }
    }

    private var tabBackground: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color(red: 0.08, green: 0.08, blue: 0.09).opacity(0.96))
            : AnyShapeStyle(.ultraThinMaterial)
    }
}
