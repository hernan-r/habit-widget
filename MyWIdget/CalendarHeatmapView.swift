import SwiftUI

struct CalendarHeatmapView: View {
    @Environment(\.colorScheme) private var colorScheme
    let habits: [Habit]

    private var days: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        // últimos 28 días
        return (0..<28).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Últimos 28 días")
                .font(.headline)
                .foregroundStyle(Gruvbox.foreground(colorScheme))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    let ratio = HabitStore.completionRatio(on: day, habits: habits)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color(for: ratio))
                        .frame(height: 24)
                        .overlay(
                            Text("\(Calendar.current.component(.day, from: day))")
                                .font(.caption2)
                                .foregroundStyle(Gruvbox.foreground(colorScheme).opacity(0.7))
                        )
                }
            }
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func color(for ratio: Double) -> Color {
        if ratio == 0 { return Gruvbox.gray.opacity(0.15) }
        return Gruvbox.accent.opacity(0.2 + ratio * 0.8)
    }
}
