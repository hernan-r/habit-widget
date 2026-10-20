import SwiftUI
import Charts

struct StatsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let habits: [Habit]

    private var last7: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCards
                chartCard
                streaksCard
            }
            .padding()
        }
        .background(Gruvbox.background(colorScheme).ignoresSafeArea())
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            statCard(title: "Completados hoy", value: "\(habits.filter(\.isDone).count)", color: Gruvbox.green)
            statCard(title: "Mejor racha", value: "\(habits.map(\.currentStreak).max() ?? 0)", color: Gruvbox.accent)
            statCard(title: "Total hábitos", value: "\(habits.count)", color: Gruvbox.blue)
        }
    }

    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack {
            Text(value).font(.title.bold()).foregroundStyle(color)
            Text(title).font(.caption).foregroundStyle(Gruvbox.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chartCard: some View {
        VStack(alignment: .leading) {
            Text("Completados (7 días)").font(.headline).foregroundStyle(Gruvbox.foreground(colorScheme))
            Chart {
                ForEach(last7, id: \.self) { day in
                    BarMark(
                        x: .value("Día", day, unit: .day),
                        y: .value("Completados", habits.filter { h in h.completionDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: day) }) }.count)
                    )
                    .foregroundStyle(Gruvbox.accent)
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var streaksCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rachas").font(.headline).foregroundStyle(Gruvbox.foreground(colorScheme))
            ForEach(habits) { h in
                HStack {
                    Image(systemName: h.icon).foregroundStyle(h.category.color)
                    Text(h.name).foregroundStyle(Gruvbox.foreground(colorScheme))
                    Spacer()
                    Text("🔥 \(h.currentStreak)").foregroundStyle(Gruvbox.accent)
                }
            }
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
