import SwiftUI
import WidgetKit
import AppIntents

struct HabitWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    var entry: HabitEntry

    var completed: Int { entry.habits.filter(\.isDone).count }
    var progress: Double {
        entry.habits.isEmpty ? 0 : Double(completed) / Double(entry.habits.count)
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            case .systemLarge:
                largeView
            case .accessoryCircular:
                circularView
            case .accessoryRectangular:
                rectangularView
            case .accessoryInline:
                inlineView
            default:
                smallView
            }
        }
        .containerBackground(Gruvbox.background(colorScheme), for: .widget)
        .preferredColorScheme(.dark)
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().stroke(Gruvbox.gray.opacity(0.3), lineWidth: 6)
                Circle().trim(from: 0, to: progress)
                    .stroke(Gruvbox.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(completed)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Gruvbox.foreground(colorScheme))
            }
            .frame(width: 60, height: 60)
            Text("de \(entry.habits.count)")
                .font(.caption2).foregroundStyle(Gruvbox.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediumView: some View {
        HStack(spacing: 12) {
            progressRing(size: 70, lineWidth: 8)
            habitList(limit: 4)
        }
        .padding()
    }

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                progressRing(size: 60, lineWidth: 6)
                VStack(alignment: .leading) {
                    Text(entry.category?.rawValue ?? "Todos").font(.headline).foregroundStyle(Gruvbox.foreground(colorScheme))
                    Text("\(completed)/\(entry.habits.count) completados").font(.caption).foregroundStyle(Gruvbox.gray)
                }
                Spacer()
            }
            Divider().background(Gruvbox.gray.opacity(0.3))
            habitList(limit: 8)
            Spacer(minLength: 0)
        }
        .padding()
    }

    private var circularView: some View {
        ZStack {
            Circle().stroke(Gruvbox.gray.opacity(0.3), lineWidth: 4)
            Circle().trim(from: 0, to: progress)
                .stroke(Gruvbox.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(completed)").font(.caption.bold()).foregroundStyle(Gruvbox.foreground(colorScheme))
        }
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(completed)/\(entry.habits.count) hábitos").font(.caption.bold()).foregroundStyle(Gruvbox.foreground(colorScheme))
            ForEach(entry.habits.prefix(2)) { habit in
                HStack(spacing: 4) {
                    Button(intent: ToggleHabitIntent(habitID: habit.id.uuidString)) {
                        Image(systemName: habit.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.caption2)
                            .foregroundStyle(habit.isDone ? Gruvbox.green : Gruvbox.gray)
                    }
                    .buttonStyle(.plain)
                    Text(habit.name).font(.caption2).lineLimit(1).foregroundStyle(Gruvbox.foreground(colorScheme))
                }
            }
        }
    }

    private var inlineView: some View {
        Text("\(completed)/\(entry.habits.count) hábitos")
    }

    private func progressRing(size: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle().stroke(Gruvbox.gray.opacity(0.3), lineWidth: lineWidth)
            Circle().trim(from: 0, to: progress)
                .stroke(Gruvbox.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%").font(.caption2.bold()).foregroundStyle(Gruvbox.foreground(colorScheme))
        }
        .frame(width: size, height: size)
    }

    private func habitList(limit: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(entry.habits.prefix(limit)) { habit in
                HStack(spacing: 6) {
                    Button(intent: ToggleHabitIntent(habitID: habit.id.uuidString)) {
                        Image(systemName: habit.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(habit.isDone ? Gruvbox.green : Gruvbox.gray)
                    }
                    .buttonStyle(.plain)
                    Text(habit.name).font(.caption).lineLimit(1).foregroundStyle(Gruvbox.foreground(colorScheme))
                        .strikethrough(habit.isDone, color: Gruvbox.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
