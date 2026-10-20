import SwiftData
import Foundation

enum HabitStore {
    static func load(context: ModelContext = HabitContainer.context) -> [Habit] {
        resetIfNeeded(context: context)
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        let result = (try? context.fetch(descriptor)) ?? []
        if result.isEmpty {
            let samples = sampleHabits
            samples.forEach { context.insert($0) }
            try? context.save()
            return samples
        }
        return result
    }

    static func save(context: ModelContext = HabitContainer.context) {
        try? context.save()
    }

    static func insert(_ habit: Habit, context: ModelContext = HabitContainer.context) {
        context.insert(habit)
        try? context.save()
    }

    static func delete(_ habit: Habit, context: ModelContext = HabitContainer.context) {
        context.delete(habit)
        try? context.save()
    }

    static func deleteAll(context: ModelContext = HabitContainer.context) {
        let descriptor = FetchDescriptor<Habit>()
        if let all = try? context.fetch(descriptor) {
            for h in all { context.delete(h) }
            try? context.save()
        }
    }

    static func resetIfNeeded(context: ModelContext = HabitContainer.context) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let lastReset = UserDefaults.standard.object(forKey: "lastResetDate") as? Date
        if let lastReset, cal.isDate(lastReset, inSameDayAs: today) { return }
        let descriptor = FetchDescriptor<Habit>()
        if let habits = try? context.fetch(descriptor) {
            for h in habits { h.isDone = false }
            try? context.save()
        }
        UserDefaults.standard.set(today, forKey: "lastResetDate")
    }

    static func markCompleted(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        if !habit.completionDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            habit.completionDates.append(today)
        }
        habit.isDone = true
    }

    static func unmarkCompleted(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        habit.completionDates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
        habit.isDone = false
    }

    static func completionRatio(on date: Date, habits: [Habit]) -> Double {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        let applicable = habits.filter { $0.frequency.applies(on: day) }
        guard !applicable.isEmpty else { return 0 }
        let done = applicable.filter { h in h.completionDates.contains(where: { cal.isDate($0, inSameDayAs: day) }) }.count
        return Double(done) / Double(applicable.count)
    }

    static func exportJSON(_ habits: [Habit]) -> Data? {
        // Use a simple DTO
        let dtos = habits.map { HabitDTO(from: $0) }
        return try? JSONEncoder().encode(dtos)
    }

    static func exportCSV(_ habits: [Habit]) -> String {
        var lines = ["Nombre,Categoría,Frecuencia,Completado"]
        for h in habits {
            lines.append("\(h.name),\(h.category.rawValue),\(h.frequency.displayName),\(h.isDone)")
        }
        return lines.joined(separator: "\n")
    }

    static func importJSON(_ data: Data, context: ModelContext = HabitContainer.context) -> [Habit]? {
        guard let dtos = try? JSONDecoder().decode([HabitDTO].self, from: data) else { return nil }
        let habits = dtos.map { $0.toHabit() }
        habits.forEach { context.insert($0) }
        try? context.save()
        return habits
    }

    static let sampleHabits: [Habit] = [
        Habit(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Beber agua", icon: "drop.fill", category: .health, frequency: .daily),
        Habit(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Leer 10 min", icon: "book.fill", category: .personal, frequency: .daily),
        Habit(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Caminar", icon: "figure.walk", category: .health, frequency: .timesPerWeek(3)),
    ]
}

struct HabitDTO: Codable {
    let id: UUID
    let name: String
    let isDone: Bool
    let createdAt: Date
    let icon: String
    let categoryRaw: String
    let frequencyData: Data
    let completionDates: [Date]
    let reminderTime: Date?

    init(from h: Habit) {
        id = h.id; name = h.name; isDone = h.isDone; createdAt = h.createdAt; icon = h.icon
        categoryRaw = h.categoryRaw; frequencyData = h.frequencyData; completionDates = h.completionDates; reminderTime = h.reminderTime
    }

    func toHabit() -> Habit {
        let h = Habit(id: id, name: name, isDone: isDone, icon: icon, category: HabitCategory(rawValue: categoryRaw) ?? .personal, reminderTime: reminderTime)
        h.createdAt = createdAt
        h.frequencyData = frequencyData
        h.completionDates = completionDates
        return h
    }
}
