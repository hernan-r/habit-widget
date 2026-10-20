import SwiftData
import Foundation

@Model
final class Habit {
    var id: UUID
    var name: String
    var isDone: Bool
    var createdAt: Date
    var icon: String
    var categoryRaw: String
    var frequencyData: Data
    var completionDates: [Date]
    var reminderTime: Date?

    init(id: UUID = UUID(), name: String, isDone: Bool = false, icon: String = "checkmark.circle",
         category: HabitCategory = .personal, frequency: HabitFrequency = .daily, reminderTime: Date? = nil) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.createdAt = .now
        self.icon = icon
        self.categoryRaw = category.rawValue
        self.frequencyData = (try? JSONEncoder().encode(frequency)) ?? Data()
        self.completionDates = []
        self.reminderTime = reminderTime
    }

    var category: HabitCategory {
        get { HabitCategory(rawValue: categoryRaw) ?? .personal }
        set { categoryRaw = newValue.rawValue }
    }

    var frequency: HabitFrequency {
        get { (try? JSONDecoder().decode(HabitFrequency.self, from: frequencyData)) ?? .daily }
        set { frequencyData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        let completedSet = Set(completionDates.map { cal.startOfDay(for: $0) })
        while completedSet.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}
