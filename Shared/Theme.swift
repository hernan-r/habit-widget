import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case gruvboxDark = "Gruvbox Dark"
    case gruvboxLight = "Gruvbox Light"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .gruvboxDark: return .dark
        case .gruvboxLight: return .light
        }
    }

    var accent: Color {
        switch self {
        case .gruvboxDark, .gruvboxLight: return Color("GruvboxAccent")
        }
    }

    var background: Color {
        switch self {
        case .gruvboxDark, .gruvboxLight: return Color("GruvboxBg")
        }
    }

    var surface: Color {
        switch self {
        case .gruvboxDark, .gruvboxLight: return Color("GruvboxBg1")
        }
    }

    var foreground: Color {
        switch self {
        case .gruvboxDark, .gruvboxLight: return Color("GruvboxFg")
        }
    }
}
