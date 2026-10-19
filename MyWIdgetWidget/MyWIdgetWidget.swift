import WidgetKit
import SwiftUI
import AppIntents

@main
struct MyWIdgetWidget: Widget {
    let kind = "MyWIdgetWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectCategoryIntent.self, provider: Provider()) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Hábitos")
        .description("Seguimiento de tus hábitos.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryCircular, .accessoryRectangular, .accessoryInline
        ])
    }
}
