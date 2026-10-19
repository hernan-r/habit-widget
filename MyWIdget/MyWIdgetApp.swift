import SwiftUI

@main
struct MyWIdgetApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem { Label("Hábitos", systemImage: "checkmark.circle") }
                StatsTabView()
                    .tabItem { Label("Stats", systemImage: "chart.bar") }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct StatsTabView: View {
    @State private var habits: [Habit] = HabitStore.load()
    var body: some View {
        NavigationStack {
            StatsView(habits: habits)
                .navigationTitle("Estadísticas")
        }
        .onAppear { habits = HabitStore.load() }
    }
}
