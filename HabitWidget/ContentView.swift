import SwiftUI
import WidgetKit
import UIKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var newHabitName: String = ""
    @State private var selectedIcon: String = "checkmark.circle"
    @State private var selectedCategory: HabitCategory = .personal
    @State private var freqMode: Int = 0
    @State private var selectedWeekdays: Set<Int> = []
    @State private var timesPerWeek: Int = 3
    @State private var showAddSheet: Bool = false
    @State private var editingHabit: Habit? = nil
    @State private var filterCategory: HabitCategory? = nil
    @State private var showDeleteAllAlert = false
    @State private var shouldDeleteAll = false

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
                List {
                    Section {
                        filterBar
                        progressCard
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Section {
                        if filtered.isEmpty {
                            emptyState
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        } else {
                            ForEach(filtered, id: \.id) { habit in
                                HabitRow(habit: habit, colorScheme: colorScheme) {
                                    if habit.isDone { HabitStore.markCompleted(habit); UIImpactFeedbackGenerator(style: .medium).impactOccurred() } else { HabitStore.unmarkCompleted(habit); UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                                    try? context.save()
                                    WidgetCenter.shared.reloadAllTimelines()
                                } onEdit: { editingHabit = habit } onDelete: {
                                    context.delete(habit)
                                    try? context.save()
                                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        context.delete(habit)
                                        try? context.save()
                                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                        WidgetCenter.shared.reloadAllTimelines()
                                    } label: { Label("Eliminar", systemImage: "trash") }
                                    Button {
                                        editingHabit = habit
                                    } label: { Label("Editar", systemImage: "pencil") }
                                    .tint(Gruvbox.blue)
                                }
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .transition(reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
                            }
                            .onDelete { indexSet in
                                for i in indexSet {
                                    let h = filtered[i]
                                    context.delete(h)
                                }
                                try? context.save()
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                    }
                    .listRowSeparator(.hidden)

                    Section {
                        CalendarHeatmapView(habits: habits)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8), value: habits.count)
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(Gruvbox.accent)
                    }
                    .accessibilityLabel("Agregar hábito")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button { resetAll() } label: { Label("Reiniciar", systemImage: "arrow.counterclockwise") }
                        Button(role: .destructive) { showDeleteAllAlert = true } label: { Label("Eliminar todos", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(Gruvbox.gray)
                    }
                    .accessibilityLabel("Más opciones")
                    .disabled(habits.isEmpty)
                }
            }
            .alert("Eliminar todos", isPresented: $showDeleteAllAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Eliminar", role: .destructive) { shouldDeleteAll = true }
            } message: {
                Text("Se eliminarán todos los hábitos. Esta acción no se puede deshacer.")
            }
            .sheet(isPresented: $showAddSheet) { addSheet }
            .sheet(item: $editingHabit) { h in
                HabitEditSheet(habit: h) {
                    try? context.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
        .task { seedIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { HabitStore.resetIfNeeded(context: context) }
        }
        .onChange(of: shouldDeleteAll) { _, newValue in
            guard newValue else { return }
            Task { @MainActor in
                HabitStore.deleteAll(context: context)
                try? context.save()
                WidgetCenter.shared.reloadAllTimelines()
                shouldDeleteAll = false
            }
        }
    }

    private func seedIfNeeded() {
        let descriptor = FetchDescriptor<Habit>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            for h in HabitStore.sampleHabits { context.insert(h) }
            try? context.save()
        }
        HabitStore.resetIfNeeded(context: context)
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
        .accessibilityLabel(label)
        .accessibilityAddTraits(filterCategory == cat ? .isSelected : [])
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
            ForEach(filtered, id: \.id) { habit in
                HabitRow(habit: habit, colorScheme: colorScheme) {
                    if habit.isDone { HabitStore.markCompleted(habit); UIImpactFeedbackGenerator(style: .medium).impactOccurred() } else { HabitStore.unmarkCompleted(habit); UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                    try? context.save()
                    WidgetCenter.shared.reloadAllTimelines()
                } onEdit: { editingHabit = habit } onDelete: {
                    context.delete(habit)
                    try? context.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(Gruvbox.accent)

            Text("Sin hábitos todavía")
                .font(.title3.bold())
                .foregroundStyle(Gruvbox.foreground(colorScheme))
            Text("Tocá + para agregar tu primer hábito y empezar a construir tu racha.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Gruvbox.gray)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
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
                        let h = Habit(name: trimmed, icon: selectedIcon, category: selectedCategory, frequency: freq)
                        context.insert(h)
                        try? context.save()
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
        for h in habits { h.isDone = false }
        try? context.save()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct HabitRow: View {
    let habit: Habit
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
            Toggle("", isOn: Binding(get: { habit.isDone }, set: { newVal in
                habit.isDone = newVal
                onChange()
            }))
                .labelsHidden().tint(Gruvbox.accent)
            Button(role: .destructive) { onDelete() } label: {
                Image(systemName: "trash").foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Gruvbox.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(habit.name), \(habit.category.rawValue), \(habit.frequency.displayName)")
        .accessibilityValue(habit.isDone ? "Completado" : "Pendiente")
        .accessibilityHint(habit.isDone ? "Doble toque para marcar como pendiente" : "Doble toque para marcar como completado")
        .accessibilityAction(named: habit.isDone ? "Desmarcar" : "Completar") { onChange() }
        .contextMenu {
            Button { onEdit() } label: { Label("Editar", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Eliminar", systemImage: "trash") }
        }
    }
}

#Preview { ContentView() }
