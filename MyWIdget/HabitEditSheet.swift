import SwiftUI

struct HabitEditSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var habit: Habit
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void

    @State private var name: String = ""
    @State private var selectedIcon: String = "checkmark.circle"
    @State private var category: HabitCategory = .personal
    @State private var freqMode: Int = 0
    @State private var selectedWeekdays: Set<Int> = []
    @State private var timesPerWeek: Int = 3

    let icons = ["checkmark.circle", "drop.fill", "book.fill", "figure.walk", "heart.fill", "star.fill", "moon.fill", "sun.max.fill", "flame.fill", "bolt.fill"]
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        NavigationStack {
            Form {
                Section("Nombre") { TextField("Nombre", text: $name) }
                Section("Categoría") {
                    Picker("Categoría", selection: $category) {
                        ForEach(HabitCategory.allCases) { c in
                            Label(c.rawValue, systemImage: c.icon).tag(c)
                        }
                    }.pickerStyle(.segmented)
                }
                Section("Icono") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                        ForEach(icons, id: \.self) { icon in
                            Button { selectedIcon = icon } label: {
                                Image(systemName: icon).font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? category.color : Gruvbox.gray)
                                    .padding(6)
                                    .background(selectedIcon == icon ? category.color.opacity(0.15) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                }
                Section("Frecuencia") {
                    Picker("Modo", selection: $freqMode) {
                        Text("Diario").tag(0)
                        Text("Días específicos").tag(1)
                        Text("X por semana").tag(2)
                    }.pickerStyle(.segmented)
                    if freqMode == 1 {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                            ForEach(1...7, id: \.self) { wd in
                                let sym = weekdaySymbols.indices.contains(wd-1) ? weekdaySymbols[wd-1] : "\(wd)"
                                Button {
                                    if selectedWeekdays.contains(wd) { selectedWeekdays.remove(wd) } else { selectedWeekdays.insert(wd) }
                                } label: {
                                    Text(sym).font(.caption.bold())
                                        .frame(width: 36, height: 36)
                                        .background(selectedWeekdays.contains(wd) ? category.color : Gruvbox.surface(colorScheme))
                                        .foregroundStyle(selectedWeekdays.contains(wd) ? Color.black : Gruvbox.foreground(colorScheme))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if freqMode == 2 {
                        Stepper("Veces por semana: \(timesPerWeek)", value: $timesPerWeek, in: 1...7)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Gruvbox.background(colorScheme))
            .navigationTitle("Editar hábito")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        habit.name = name.isEmpty ? habit.name : name
                        habit.icon = selectedIcon
                        habit.category = category
                        habit.frequency = buildFrequency()
                        onSave()
                        dismiss()
                    }
                }
            }
            .onAppear {
                name = habit.name
                selectedIcon = habit.icon
                category = habit.category
                switch habit.frequency {
                case .daily: freqMode = 0
                case .weekdays(let d): freqMode = 1; selectedWeekdays = d
                case .timesPerWeek(let n): freqMode = 2; timesPerWeek = n
                }
            }
        }
    }

    private func buildFrequency() -> HabitFrequency {
        switch freqMode {
        case 1: return .weekdays(selectedWeekdays.isEmpty ? [1] : selectedWeekdays)
        case 2: return .timesPerWeek(timesPerWeek)
        default: return .daily
        }
    }
}
