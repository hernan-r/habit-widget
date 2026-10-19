import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var habits: [Habit] = HabitStore.load()
    @State private var newHabitName: String = ""
    @State private var selectedIcon: String = "checkmark.circle"
    @State private var selectedCategory: HabitCategory = .personal
    @State private var freqMode: Int = 0
    @State private var selectedWeekdays: Set<Int> = []
    @State private var timesPerWeek: Int = 3
    @State private var showAddSheet: Bool = false
    @State private var editingHabit: Habit? = nil
    @State private var filterCategory: HabitCategory? = nil

    private var filtered: [Habit] {
        guard let f = filterCategory else { return habits }
        return habits.filter { $0.category == f }
    }
    private var completed: Int { filtered.filter(\.isDone).count }
    private var progress: Double {
        filtered.isEmpty ? 0 : Double(completed) / Double(filtered.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Gruvbox.background(colorScheme).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        filterBar
                        progressCard
                        habitsList
                        CalendarHeatmapView(habits: habits)
                        if filtered.isEmpty { emptyState }
                    }
                    .padding()
                }
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(Gruvbox.accent)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button { resetAll() } label: {
                        Image(systemName: "arrow.counterclockwise").foregroundStyle(Gruvbox.gray)
                    }
                    .disabled(habits.isEmpty)
                }
            }
            .sheet(isPresented: $showAddSheet) { addSheet }
            .sheet(item: $editingHabit) { h in
                if let idx = habits.firstIndex(where: { $0.id == h.id }) {
                    HabitEditSheet(habit: $habits[idx]) {
                        HabitStore.save(habits)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
        .onAppear { habits = HabitStore.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                habits = HabitStore.load()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                filterChip(nil, label: "Todos")
                ForEach(HabitCategory.allCases) { c in
                    filterChip(c, label: c.rawValue)
                }
            }
        }
    }

    private func filterChip(_ cat: HabitCategory?, label: String) -> some View {
        Button {
            filterCategory = cat
        } label: {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(filterCategory == cat ? (cat?.color ?? Gruvbox.accent) : Gruvbox.surface(colorScheme))
                .foregroundStyle(filterCategory == cat ? Color.black : Gruvbox.foreground(colorScheme))
                .clipShape(Capsule())
        }
    }

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Progreso de hoy").font(.headline).foregroundStyle(Gruvbox.foreground(colorScheme))
                    Text("\(completed) de \(filtered.count) completados").font(.subheadline).foregroundStyle(Gruvbox.gray)
                }
                Spacer()
                ZStack {
                    Circle().stroke(Gruvbox.gray.opacity(0.3), lineWidth: 8)
                    Circle().trim(from: 0, to: progress)
                        .stroke(Gruvbox.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90)).animation(.easeInOut, value: progress)
                    Text("\(Int(progress * 100))%").font(.caption.bold()).foregroundStyle(Gruvbox.foreground(colorScheme))
                }.frame(width: 60, height: 60)
            }
            ProgressView(value: progress).tint(Gruvbox.accent)
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var habitsList: some View {
        VStack(spacing: 8) {
            ForEach($habits) { $habit in
                if filterCategory == nil || habit.category == filterCategory {
                    HabitRow(habit: $habit, colorScheme: colorScheme) {
                        if habit.isDone { HabitStore.markCompleted(&habit) } else { HabitStore.unmarkCompleted(&habit) }
                        HabitStore.save(habits)
                        WidgetCenter.shared.reloadAllTimelines()
                    } onEdit: { editingHabit = habit } onDelete: {
                        habits.removeAll { $0.id == habit.id }
                        HabitStore.save(habits)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(Gruvbox.gray)
            Text("Sin hábitos todavía").foregroundStyle(Gruvbox.gray)
            Text("Tocá + para agregar uno").font(.caption).foregroundStyle(Gruvbox.gray)
        }.padding(.top, 40)
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                Section("Nuevo hábito") {
                    TextField("Nombre", text: $newHabitName)
                }
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases) { c in
                            Label(c.rawValue, systemImage: c.icon).tag(c)
                        }
                    }.pickerStyle(.segmented)
                }
                Section("Icono") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                        ForEach(["checkmark.circle", "drop.fill", "book.fill", "figure.walk", "heart.fill", "star.fill", "moon.fill", "sun.max.fill", "flame.fill"], id: \.self) { icon in
                            Button { selectedIcon = icon } label: {
                                Image(systemName: icon).font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? selectedCategory.color : Gruvbox.gray)
                                    .padding(6)
                                    .background(selectedIcon == icon ? selectedCategory.color.opacity(0.15) : Color.clear)
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
                                let sym = Calendar.current.shortWeekdaySymbols.indices.contains(wd-1) ? Calendar.current.shortWeekdaySymbols[wd-1] : "\(wd)"
                                Button {
                                    if selectedWeekdays.contains(wd) { selectedWeekdays.remove(wd) } else { selectedWeekdays.insert(wd) }
                                } label: {
                                    Text(sym).font(.caption.bold())
                                        .frame(width: 36, height: 36)
                                        .background(selectedWeekdays.contains(wd) ? selectedCategory.color : Gruvbox.surface(colorScheme))
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
            .navigationTitle("Agregar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        showAddSheet = false; newHabitName = ""; selectedIcon = "checkmark.circle"; selectedCategory = .personal; freqMode = 0; selectedWeekdays = []; timesPerWeek = 3
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let trimmed = newHabitName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let freq: HabitFrequency = {
                            switch freqMode {
                            case 1: return .weekdays(selectedWeekdays.isEmpty ? [1] : selectedWeekdays)
                            case 2: return .timesPerWeek(timesPerWeek)
                            default: return .daily
                            }
                        }()
                        var h = Habit(name: trimmed, icon: selectedIcon, category: selectedCategory, frequency: freq)
                        if h.isDone { HabitStore.markCompleted(&h) }
                        habits.append(h)
                        HabitStore.save(habits)
                        WidgetCenter.shared.reloadAllTimelines()
                        newHabitName = ""; selectedIcon = "checkmark.circle"; selectedCategory = .personal; freqMode = 0; selectedWeekdays = []; timesPerWeek = 3
                        showAddSheet = false
                    }
                    .disabled(newHabitName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func resetAll() {
        for i in habits.indices { habits[i].isDone = false }
        HabitStore.save(habits)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct HabitRow: View {
    @Binding var habit: Habit
    let colorScheme: ColorScheme
    let onChange: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.icon)
                .foregroundStyle(habit.isDone ? Gruvbox.green : habit.category.color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .foregroundStyle(Gruvbox.foreground(colorScheme))
                    .strikethrough(habit.isDone, color: Gruvbox.gray)
                Text("\(habit.category.rawValue) · \(habit.frequency.displayName)")
                    .font(.caption2).foregroundStyle(Gruvbox.gray)
            }
            Spacer()
            Text("🔥\(habit.currentStreak)").font(.caption).foregroundStyle(Gruvbox.accent)
            Toggle("", isOn: $habit.isDone)
                .labelsHidden().tint(Gruvbox.accent)
                .onChange(of: habit.isDone) { _, _ in onChange() }
            Button(role: .destructive) { onDelete() } label: {
                Image(systemName: "trash").foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button { onEdit() } label: { Label("Editar", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Eliminar", systemImage: "trash") }
        }
    }
}

#Preview { ContentView() }
