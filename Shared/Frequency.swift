import Foundation

enum HabitFrequency: Codable, Equatable, Hashable {
    case daily
    case weekdays(Set<Int>)   // 1...7 (1 = domingo en Calendar, ajustar)
    case timesPerWeek(Int)

    var displayName: String {
        switch self {
        case .daily: return "Diario"
        case .weekdays(let days):
            let names = days.sorted().map { weekdayName($0) }
            return names.joined(separator: ", ")
        case .timesPerWeek(let n): return "\(n)x por semana"
        }
    }

    func applies(on date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .daily:
            return true
        case .weekdays(let days):
            let wd = calendar.component(.weekday, from: date)
            return days.contains(wd)
        case .timesPerWeek:
            return true
        }
    }

    private func weekdayName(_ wd: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        // Calendar weekday: 1 = domingo
        guard wd >= 1, wd <= 7 else { return "" }
        return symbols[wd - 1]
    }
}
