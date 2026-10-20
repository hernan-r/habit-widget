import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case gruvboxDark = "Gruvbox Dark"
    case gruvboxLight = "Gruvbox Light"
    case ocean = "Ocean"
    case sunset = "Sunset"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .gruvboxDark: return .dark
        case .gruvboxLight: return .light
        default: return nil
        }
    }

    var accent: Color {
        switch self {
        case .gruvboxDark, .gruvboxLight: return Gruvbox.accent
        case .ocean: return Color(hex: 0x0ea5e9)
        case .sunset: return Color(hex: 0xf97316)
        }
    }
}
