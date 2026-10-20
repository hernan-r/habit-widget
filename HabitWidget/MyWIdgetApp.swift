import SwiftUI
import SwiftData

@main
struct HabitWidgetApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @AppStorage("selectedTheme") private var selectedTheme: String = AppTheme.gruvboxDark.rawValue
    @State private var showOnboarding = false

    var theme: AppTheme { AppTheme(rawValue: selectedTheme) ?? .gruvboxDark }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasOnboarded {
                    OnboardingView(isPresented: $showOnboarding)
                        .onAppear { showOnboarding = true }
                } else {
                    TabView {
                        ContentView()
                            .tabItem { Label("Hábitos", systemImage: "checkmark.circle") }
                        StatsTabView()
                            .tabItem { Label("Stats", systemImage: "chart.bar") }
                        SettingsView()
                            .tabItem { Label("Ajustes", systemImage: "gear") }
                    }
                }
            }
            .modelContainer(HabitContainer.container)
            .preferredColorScheme(theme.colorScheme)
            .onAppear {
                NotificationManager.requestAuthorization()
                if !hasOnboarded { showOnboarding = true }
            }
        }
    }
}

struct StatsTabView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    var body: some View {
        NavigationStack {
            StatsView(habits: habits)
                .navigationTitle("Estadísticas")
        }
    }
}
