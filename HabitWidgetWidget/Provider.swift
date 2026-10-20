import WidgetKit
import SwiftUI

struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let category: HabitCategory?
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: .now, habits: HabitStore.load(), category: nil)
    }

    func snapshot(for configuration: SelectCategoryIntent, in context: Context) async -> HabitEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: SelectCategoryIntent, in context: Context) async -> Timeline<HabitEntry> {
        let e = entry(for: configuration)
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(15 * 60)
        return Timeline(entries: [e], policy: .after(next))
    }

    private func entry(for configuration: SelectCategoryIntent) -> HabitEntry {
        let all = HabitStore.load()
        let cat = configuration.category?.habitCategory
        let filtered = cat == nil ? all : all.filter { $0.category == cat }
        return HabitEntry(date: .now, habits: filtered, category: cat)
    }
}
