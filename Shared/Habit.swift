import Foundation

struct Habit: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var isDone: Bool
    var createdAt: Date
    var icon: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var completionDates: [Date]

    init(id: UUID = UUID(), name: String, isDone: Bool = false, icon: String = "checkmark.circle",
         category: HabitCategory = .personal, frequency: HabitFrequency = .daily) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.createdAt = .now
        self.icon = icon
        self.category = category
        self.frequency = frequency
        self.completionDates = []
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

    enum CodingKeys: String, CodingKey {
        case id, name, isDone, createdAt, icon, category, frequency, completionDates
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        isDone = try c.decode(Bool.self, forKey: .isDone)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? .now
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? "checkmark.circle"
        category = try c.decodeIfPresent(HabitCategory.self, forKey: .category) ?? .personal
        frequency = try c.decodeIfPresent(HabitFrequency.self, forKey: .frequency) ?? .daily
        completionDates = try c.decodeIfPresent([Date].self, forKey: .completionDates) ?? []
    }
}
