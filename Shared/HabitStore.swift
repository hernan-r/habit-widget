import Foundation

enum HabitStore {
    static let appGroupID = "group.com.curso.CoinFlip.MyWIdget"
    static let habitsKey = "habits"
    static let lastResetKey = "lastResetDate"

    static var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupID) }

    static func load() -> [Habit] {
        resetIfNeeded()
        guard let data = sharedDefaults?.data(forKey: habitsKey) else { return sampleHabits }
        return (try? JSONDecoder().decode([Habit].self, from: data)) ?? sampleHabits
    }

    static func save(_ habits: [Habit]) {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        sharedDefaults?.set(data, forKey: habitsKey)
    }

    /// Reinicio automático a medianoche.
    static func resetIfNeeded() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let last = sharedDefaults?.object(forKey: lastResetKey) as? Date
        if let last, cal.isDate(last, inSameDayAs: today) { return }
        // Reset isDone
        if let data = sharedDefaults?.data(forKey: habitsKey),
           var habits = try? JSONDecoder().decode([Habit].self, from: data) {
            for i in habits.indices { habits[i].isDone = false }
            if let d = try? JSONEncoder().encode(habits) {
                sharedDefaults?.set(d, forKey: habitsKey)
            }
        }
        sharedDefaults?.set(today, forKey: lastResetKey)
    }

    static func markCompleted(_ habit: inout Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        if !habit.completionDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            habit.completionDates.append(today)
        }
    }

    static func unmarkCompleted(_ habit: inout Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        habit.completionDates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
    }

    /// Ratio de completados para un día dado (0...1).
    static func completionRatio(on date: Date, habits: [Habit]) -> Double {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        let applicable = habits.filter { $0.frequency.applies(on: day) }
        guard !applicable.isEmpty else { return 0 }
        let done = applicable.filter { h in h.completionDates.contains(where: { cal.isDate($0, inSameDayAs: day) }) }.count
        return Double(done) / Double(applicable.count)
    }

    static let sampleHabits: [Habit] = [
        Habit(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Beber agua", icon: "drop.fill", category: .health, frequency: .daily),
        Habit(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Leer 10 min", icon: "book.fill", category: .personal, frequency: .daily),
        Habit(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Caminar", icon: "figure.walk", category: .health, frequency: .timesPerWeek(3)),
    ]
}
