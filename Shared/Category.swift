import SwiftUI

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health = "Salud"
    case work = "Trabajo"
    case personal = "Personal"
    case other = "Otro"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .health: return Gruvbox.green
        case .work: return Gruvbox.blue
        case .personal: return Gruvbox.purple
        case .other: return Gruvbox.gray
        }
    }

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .other: return "star.fill"
        }
    }
}
