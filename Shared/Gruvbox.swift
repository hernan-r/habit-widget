import SwiftUI

enum Gruvbox {
    static var bg: Color { Color("GruvboxBg") }
    static var bg1: Color { Color("GruvboxBg1") }
    static var fg: Color { Color("GruvboxFg") }
    static var red: Color { Color("GruvboxRed") }
    static var green: Color { Color("GruvboxGreen") }
    static var yellow: Color { Color("GruvboxYellow") }
    static var blue: Color { Color("GruvboxBlue") }
    static var purple: Color { Color("GruvboxPurple") }
    static var aqua: Color { Color("GruvboxAqua") }
    static var orange: Color { Color("GruvboxOrange") }
    static var gray: Color { Color("GruvboxGray") }
    static var accent: Color { Color("GruvboxAccent") }

    static func background(_ scheme: ColorScheme) -> Color { bg }
    static func surface(_ scheme: ColorScheme) -> Color { bg1 }
    static func foreground(_ scheme: ColorScheme) -> Color { fg }
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
