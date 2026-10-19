import AppIntents
import Foundation
import WidgetKit

enum CategoryAppEnum: String, AppEnum {
    case all = "Todas"
    case health = "Salud"
    case work = "Trabajo"
    case personal = "Personal"
    case other = "Otro"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Categoría"

    static var caseDisplayRepresentations: [CategoryAppEnum: DisplayRepresentation] = [
        .all: "Todas",
        .health: "Salud",
        .work: "Trabajo",
        .personal: "Personal",
        .other: "Otro",
    ]

    var habitCategory: HabitCategory? {
        switch self {
        case .all: return nil
        case .health: return .health
        case .work: return .work
        case .personal: return .personal
        case .other: return .other
        }
    }
}

struct SelectCategoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Categoría del widget"
    static var description = IntentDescription("Elige qué categoría mostrar.")

    @Parameter(title: "Categoría")
    var category: CategoryAppEnum?
}

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Marcar hábito"
    static var description = IntentDescription("Marca o desmarca un hábito.")

    @Parameter(title: "ID del hábito")
    var habitID: String

    init() {}
    init(habitID: String) {
        self.habitID = habitID
    }

    func perform() async throws -> some IntentResult {
        var habits = HabitStore.load()
        if let idx = habits.firstIndex(where: { $0.id.uuidString == habitID }) {
            habits[idx].isDone.toggle()
            if habits[idx].isDone {
                HabitStore.markCompleted(&habits[idx])
            } else {
                HabitStore.unmarkCompleted(&habits[idx])
            }
            HabitStore.save(habits)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
