# Hábitos — HabitWidget

App de seguimiento de hábitos para iPhone y iPad, escrita en SwiftUI + SwiftData, con **widgets interactivos** en pantalla de inicio y pantalla de bloqueo. La estética está basada en el tema **Gruvbox**.

> Proyecto de aprendizaje de Swift/SwiftUI: código legible, estructura simple y foco en widgets, persistencia local y notificaciones.

![iOS](https://img.shields.io/badge/iOS-27.0-000000?logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-1E90FF)
![SwiftData](https://img.shields.io/badge/Storage-SwiftData-8A2BE2)

---

## Índice

- [Características](#características)
- [Widgets](#widgets)
- [Stack técnico](#stack-técnico)
- [Requisitos](#requisitos)
- [Cómo compilar y correr](#cómo-compilar-y-correr)
- [Cómo probar el widget](#cómo-probar-el-widget)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Modelo de datos](#modelo-de-datos)
- [Configuración de firma y App Group](#configuración-de-firma-y-app-group)
- [Tests](#tests)
- [Limitaciones conocidas](#limitaciones-conocidas)
- [Roadmap](#roadmap)
- [Licencia](#licencia)

---

## Características

- **Hábitos** con nombre, ícono SF Symbol, categoría y frecuencia.
- **Categorías** con color propio: Salud, Trabajo, Personal, Otro.
- **Frecuencias**: diario, días específicos de la semana o N veces por semana.
- **Rachas**: cálculo de días consecutivos completados por hábito.
- **Reset diario automático**: al abrir la app se desmarcan los hábitos del día anterior, conservando el historial de `completionDates`.
- **Progreso del día**: contador, porcentaje y anillo de progreso, con filtro por categoría.
- **Estadísticas**: totales, mejor racha, gráfico de barras de los últimos 7 días (Swift Charts) y heatmap de los últimos 28 días.
- **Recordatorios**: notificaciones locales diarias por hábito (hora configurable).
- **Onboarding** de 3 pasos para la primera apertura.
- **Temas Gruvbox** dark/light, con colores definidos como assets.
- **Exportar / importar JSON** de hábitos desde Ajustes.
- **Accesibilidad**: labels, values, hints y acciones accesibles en las filas; respeta `accessibilityReduceMotion`.
- **Háptica** al marcar, desmarcar y eliminar hábitos.

## Widgets

El target de widget (`HabitWidgetWidget`) soporta:

| Familia | Contenido |
| --- | --- |
| `systemSmall` | Anillo de progreso + completados |
| `systemMedium` | Anillo + lista de hasta 4 hábitos con toggle |
| `systemLarge` | Anillo, encabezado de categoría y lista de hasta 8 hábitos |
| `accessoryCircular` | Progreso en forma de anillo |
| `accessoryRectangular` | Dos hábitos con toggle, para pantalla de bloqueo |
| `accessoryInline` | Texto `completados/total` |

- Configuración por **App Intent**: el widget se configura por categoría (`Todas`, `Salud`, `Trabajo`, `Personal`, `Otro`).
- **Interacción sin abrir la app**: `ToggleHabitIntent` marca/desmarca el hábito y recarga las timelines.
- Timeline con refresco cada 15 minutos; la app fuerza `WidgetCenter.shared.reloadAllTimelines()` después de cada cambio.

## Stack técnico

| Área | Tecnología |
| --- | --- |
| UI | SwiftUI (`TabView`, `NavigationStack`, `Form`, `List`) |
| Persistencia | SwiftData (`@Model`, `ModelContainer`) en App Group |
| Widgets | WidgetKit + App Intents (`AppIntentConfiguration`, `AppIntentTimelineProvider`) |
| Gráficos | Swift Charts |
| Notificaciones | UserNotifications (`UNCalendarNotificationTrigger`) |
| Iconografía | SF Symbols |
| Tests | XCTest |

Sin dependencias externas ni gestores de paquetes: solo frameworks de Apple.

## Requisitos

- **macOS** con **Xcode** (el proyecto está configurado con `SWIFT_VERSION = 5.0`).
- **iOS/iPadOS 27.0** según `IPHONEOS_DEPLOYMENT_TARGET` del proyecto, sobre iPhone o iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- Una cuenta de desarrollador para ejecutar en dispositivo físico (los widgets y las notificaciones no funcionan bien solo en Playgrounds).

> **Nota**: el código usa APIs que requieren **iOS 17+** (SwiftData, `containerBackground`, widgets interactivos). Si necesitás correrlo en una versión anterior, bajá el deployment target de los tres targets a iOS 17.

## Cómo compilar y correr

1. Cloná el repositorio:

   ```bash
   git clone <URL-del-repositorio>
   cd HabitWidget
   ```

2. Abrí el proyecto:

   ```bash
   open HabitWidget.xcodeproj
   ```

3. En **Xcode → Signing & Capabilities**, seleccioná tu **Team** en los tres targets:
   - `HabitWidget` (app)
   - `HabitWidgetWidget` (extensión de widget)
   - `HabitWidgetTests`

4. Verificá que el **App Group** coincida con tu Team (ver [Configuración de firma](#configuración-de-firma-y-app-group)).

5. Elegí el scheme **HabitWidget** y corré con `⌘R` en un simulador o dispositivo.

La primera ejecución muestra el onboarding y crea 3 hábitos de ejemplo (beber agua, leer 10 min, caminar).

## Cómo probar el widget

1. Corré la app al menos una vez para que se cree el store en el App Group.
2. Volvé al Home Screen, mantené presionado un espacio vacío → **+** → buscá **Hábitos**.
3. Elegí tamaño, agregá el widget y configuralo (mantener presionado → *Editar widget*) para filtrar por categoría.
4. Para pantalla de bloqueo: mantener presionado el lock screen → *Personalizar* → agregar widget de **Hábitos**.

Si el widget aparece vacío, revisá que app y extensión compartan el mismo App Group y que hayas corrido la app al menos una vez.

## Estructura del proyecto

```
HabitWidget/
├── HabitWidget/                 # App (iOS)
│   ├── MyWIdgetApp.swift        # @main, TabView y tema global
│   ├── ContentView.swift        # Lista de hábitos, filtros, progreso, alta
│   ├── HabitEditSheet.swift     # Edición de hábito + recordatorio
│   ├── StatsView.swift          # Charts y tarjetas de resumen
│   ├── CalendarHeatmapView.swift# Heatmap de 28 días
│   ├── SettingsView.swift       # Tema, notificaciones, export/import JSON
│   ├── OnboardingView.swift     # Onboarding de 3 pasos
│   └── Assets.xcassets/         # Colores Gruvbox + AppIcon
├── HabitWidgetWidget/           # Extensión WidgetKit
│   ├── MyWIdgetWidget.swift     # Definición del widget
│   ├── Provider.swift           # TimelineProvider
│   ├── WidgetViews.swift        # Vistas por familia de widget
│   └── Assets.xcassets/
├── Shared/                      # Código compartido por app y widget
│   ├── Habit.swift              # @Model de hábito + racha
│   ├── HabitStore.swift         # CRUD, reset diario, ratio, export/import
│   ├── HabitContainer.swift     # ModelContainer en App Group
│   ├── Frequency.swift          # Frecuencias de hábito
│   ├── Category.swift           # Categorías y colores
│   ├── AppIntents.swift         # Intents del widget (config + toggle)
│   ├── NotificationManager.swift# Programación de recordatorios
│   ├── Theme.swift              # AppTheme (Gruvbox dark/light)
│   └── Gruvbox.swift            # Paleta de colores
├── HabitWidgetTests/
│   └── HabitStoreTests.swift    # Tests de la lógica de completado
├── HabitWidgetWidget-Info.plist
└── HabitWidget.xcodeproj
```

`Shared/` se compila dentro de ambos targets, así la app y el widget comparten el mismo modelo y el mismo store.

## Modelo de datos

`Habit` es un `@Model` de SwiftData:

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `id` | `UUID` | Identificador (también se usa como id de notificación) |
| `name` | `String` | Nombre del hábito |
| `isDone` | `Bool` | Estado del día actual (se resetea cada día) |
| `createdAt` | `Date` | Fecha de creación (usada para ordenar) |
| `icon` | `String` | Nombre de SF Symbol |
| `categoryRaw` | `String` | Categoría serializada (`HabitCategory`) |
| `frequencyData` | `Data` | `HabitFrequency` codificado en JSON |
| `completionDates` | `[Date]` | Historial de días completados (rachas, heatmap, stats) |
| `reminderTime` | `Date?` | Hora del recordatorio diario, si está activo |

`isDone` es el estado del día; `completionDates` es el historial. Por eso el reset diario no borra las rachas ni las estadísticas.

## Configuración de firma y App Group

App y widget comparten datos vía App Group. Los valores actuales del proyecto son:

| Elemento | Valor |
| --- | --- |
| Bundle ID app | `com.curso.CoinFlip.HabitWidget` |
| Bundle ID widget | `com.curso.CoinFlip.HabitWidget.HabitWidgetWidget` |
| App Group | `group.com.curso.CoinFlip.HabitWidget` |

Si cambiás el bundle ID o el Team, actualizá en conjunto:

1. `HabitContainer.appGroupID` en `Shared/HabitContainer.swift`.
2. Los entitlements `HabitWidget/HabitWidget.entitlements` y `HabitWidgetWidget/HabitWidgetWidget.entitlements`.

Si el App Group no coincide, el widget no encuentra datos y el store cae a Application Support local.

## Tests

```bash
# Desde Xcode: ⌘U con el scheme HabitWidget
# Desde terminal, en un simulador disponible:
xcodebuild test \
  -project HabitWidget.xcodeproj \
  -scheme HabitWidget \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Cobertura actual (`HabitWidgetTests/HabitStoreTests.swift`): ratio de completado con lista vacía, marcar y desmarcar un hábito junto con su racha.

## Limitaciones conocidas

- La sección **iCloud → Sincronizar ahora** de Ajustes es un placeholder: el store se configura con `cloudKitDatabase: .none`, así que la sincronización entre dispositivos no está implementada.
- `HabitStore.exportCSV(_:)` existe pero todavía no está expuesto en la UI.
- `HabitFrequency.timesPerWeek` es informativo en esta versión: el cálculo de rachas y el ratio usan días completados.
- Los textos de UI están en español y no hay archivos de localización (`Localizable.strings`) todavía.

## Roadmap

- [ ] Sincronización con iCloud (CloudKit) o export/import manual entre dispositivos.
- [ ] Exportar CSV desde Ajustes.
- [ ] Cálculo real de rachas para `timesPerWeek`.
- [ ] Localización (es/en) con String Catalogs.
- [ ] Tests de `resetIfNeeded`, `completionRatio` con frecuencias y export/import JSON.
- [ ] Capturas de pantalla y GIF del widget en este README.

## Licencia

Este repositorio todavía no tiene un archivo `LICENSE`. Si querés que otros puedan reutilizar el código, agregá uno (por ejemplo [MIT](https://choosealicense.com/licenses/mit/)) y actualizá esta sección.
