import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("selectedTheme") private var selectedTheme: String = AppTheme.gruvboxDark.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var exportData: Data = Data()
    @Query(sort: \Habit.createdAt) var habits: [Habit]
    @Environment(\.modelContext) private var context

    var theme: AppTheme { AppTheme(rawValue: selectedTheme) ?? .gruvboxDark }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tema") {
                    Picker("Tema", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { t in
                            Text(t.rawValue).tag(t.rawValue)
                        }
                    }
                }
                Section("Notificaciones") {
                    Toggle("Activar recordatorios", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, on in
                            if on { NotificationManager.requestAuthorization() }
                            else { UNUserNotificationCenter.current().removeAllPendingNotificationRequests() }
                        }
                }
                Section("Datos") {
                    Button("Exportar JSON") {
                        if let d = HabitStore.exportJSON(habits) { exportData = d; showExporter = true }
                    }
                    Button("Importar JSON") { showImporter = true }
                }
                Section("iCloud") {
                    Button("Sincronizar ahora") {
                        // iCloud sync via key-value not available after SwiftData migration
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Gruvbox.background(colorScheme))
            .navigationTitle("Ajustes")
            .fileExporter(isPresented: $showExporter, document: JSONDocument(data: exportData), contentType: .json, defaultFilename: "habitos.json") { _ in }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                if case .success(let url) = result, let data = try? Data(contentsOf: url), let h = HabitStore.importJSON(data, context: HabitContainer.context) {
                    HabitStore.save()
                }
            }
            .onAppear { }
        }
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { self.data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
