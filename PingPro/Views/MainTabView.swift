import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor(red: 0.01, green: 0.02, blue: 0.08, alpha: 0.95)
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.02, blue: 0.08)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                MonitorView()
                    .tabItem {
                        Label("Monitor", systemImage: "waveform.path.ecg")
                    }
                    .tag(0)

                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
            }
            .tint(NetworkTheme.accent)
        }
    }
}
