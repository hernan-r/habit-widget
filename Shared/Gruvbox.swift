import SwiftUI

enum Gruvbox {
    // Dark palette
    static let bgDark = Color(hex: 0x282828)
    static let bg1Dark = Color(hex: 0x3c3836)
    static let fgDark = Color(hex: 0xebdbb2)
    static let red = Color(hex: 0xfb4934)
    static let green = Color(hex: 0xb8bb26)
    static let yellow = Color(hex: 0xfabd2f)
    static let blue = Color(hex: 0x83a598)
    static let purple = Color(hex: 0xd3869b)
    static let aqua = Color(hex: 0x8ec07c)
    static let orange = Color(hex: 0xfe8019)
    static let gray = Color(hex: 0x928374)

    // Light palette
    static let bgLight = Color(hex: 0xfbf1c7)
    static let bg1Light = Color(hex: 0xebdbb2)
    static let fgLight = Color(hex: 0x3c3836)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Gruvbox {
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? bgDark : bgLight
    }
    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? bg1Dark : bg1Light
    }
    static func foreground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? fgDark : fgLight
    }
    static var accent: Color { orange }
}
