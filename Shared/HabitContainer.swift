import SwiftData
import Foundation

enum HabitContainer {
    static let appGroupID = "group.com.hernanr.habitwidget"

    static var storeURL: URL {
        let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("Habits.store")
    }

    static var container: ModelContainer = {
        let schema = Schema([Habit.self])
        let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback in-memory
            let mem = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [mem])
        }
    }()

    static let context: ModelContext = ModelContext(container)
}
