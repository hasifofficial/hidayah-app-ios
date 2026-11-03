# Hidayah Architecture

## Goals

- Feature-based structure with clear dependency direction.
- MVVM for feature screens.
- Shared services and UI only when genuinely reusable.
- No direct construction of networking or persistence clients inside views.
- Every dependency injectable; shared instances are only defaults.
- User data is never silently lost or replaced.
- Widget support without duplicating app-specific UI code.

## Layers

```
simple-quran/
  App/          Lifecycle, composition root, navigation, deep links
  Core/         Models, networking, persistence, tracker domain services
  Features/     Feature screens, view models, and feature components
  Shared/       Cross-feature UI, form controls, modifiers, services
  Resources/    Assets, fonts, localization, constants

simple-quranTests/   Unit tests for the app, mirroring simple-quran/
app-widgetTests/     Unit tests for the widget, mirroring app-widget/
```

Dependency direction:

```text
App ──► Features ──► Core
 │          │
 └──────────┴────► Shared
```

`Core` must not import `Features`. `Shared` must not depend on a specific feature.

## App

```
App/
  Lifecycle/
    AppController.swift
    AppDelegate.swift
    HidayahApp.swift
  Navigation/
    AppRouter.swift
    DeeplinkManager.swift
  Root/
    RootView.swift
  Base.lproj/
    LaunchScreen.storyboard
```

- `AppController` is the composition root for services and shared state. Its initializer takes the task manager, store, notification scheduler and notification center, defaulting to the shared instances.
- `RootView` owns tab and split-view navigation.
- `AppRouter` owns tab selection, navigation paths, and sheet state.
- `DeeplinkManager` maps URLs to router destinations.

## Core

```
Core/
  Models/
    Quran/
    Tracker/
    Widget/
  Networking/
    Base/
    Endpoints/
    Services/
  Persistence/
    HidayahStore.swift
    Storage.swift
  Tracker/
    TaskManager.swift
    TrackerHistoryEngine.swift
    TrackerNotificationScheduler.swift
  Extensions/
```

- `TaskManager` is the tracker domain facade. It takes its store, notification scheduler and clock (`now: () -> Date`) through `init`.
- `HidayahStore` owns SwiftData persistence, including the schema version and migration plan (see Persistence).
- `Storage` owns App Group `UserDefaults` access and the widget snapshot.
- `TrackerNotificationScheduler` posts tracker reminders through the `NotificationScheduling` protocol, which `UNUserNotificationCenter` conforms to.
- `APIClientService` and `SurahService` are stateless and `Sendable`, and use `async`/`await`. `APIClientService` takes its `URLSession` through `init`.
- `SurahCatalog` caches the surah list on disk; its cache location is injectable.
- Models are plain value/reference types with no SwiftUI dependencies.

## Features

```
Features/
  Quran/
    List/
    Detail/
    Bookmarks/
    Settings/
    Components/
  Search/
  Settings/
    SettingView.swift
    SettingViewModel.swift
    SelectionView.swift
    WidgetGuide/
      WidgetGuideView.swift
      WidgetGuideViewModel.swift
      Components/
        WidgetGuidePreviewView.swift
  Tasbih/
    TasbihView.swift
    TasbihViewModel.swift
    Components/
      TasbihBeadProgressView.swift
  Tracker/
    Home/
    Calendar/
    DayDetail/
    Levels/
    Achievements/
    TaskEditor/
    Settings/
    Components/
```

### MVVM rules

- **View** — layout, bindings, animations, and navigation callbacks only.
- **ViewModel** — `@Observable` state, derived data, validation, formatting, and feature actions.
- **Shared domain service** — injected into the view model; not created by the view.
- A screen with meaningful state or derived data gets a paired `ViewModel`.
- Feature-only components live in the feature’s `Components/` folder.
- Cross-feature components live in `Shared/UI`.

Examples:

- `WidgetGuideView` owns presentation; `WidgetGuideViewModel` owns selection and tracker-derived preview data.
- `TasbihView` owns animation/gesture presentation; `TasbihViewModel` owns counting, phrase state, and completion flow.
- `TrackerCalendarViewModel` and `TrackerDayDetailViewModel` own date/record derivation.

## Shared

```
Shared/
  Services/
    AppHaptics.swift
  UI/
    Components/
      SettingsActionRow.swift
      SettingsSectionHeader.swift
      SettingsToggleRow.swift
    Forms/
      AppFormComponents.swift
    Loading/
    Modifiers/
    Representables/
```

Shared UI examples:

- `AppFormHeader`, `AppFormCard`, `AppTextField`, `AppIconPicker`, `AppPrimaryButton`
- `SettingsActionRow`, `SettingsSectionHeader`, `SettingsToggleRow`
- `LoadAnimation`, `ShimmerBar`, `ListRowPlaceholder`
- `MailView`, `SafariView`

Naming rule: name components by responsibility, not by the first screen that used them.

## Widget extension

```
app-widget/
  AppIntents/
    ToggleTaskIntent.swift
  Widgets/
    Tracker/
      TrackerWidget.swift
      TrackerProvider.swift
      TrackerWidgetView.swift
    QuickSurah/
      QuickSurahWidget.swift
      QuickSurahConfigurationIntent.swift
      QuickSurahProvider.swift
      QuickSurahWidgetView.swift
      QuickSurahCatalog.swift
  Shared/
    WidgetFontLoader.swift
  Resources/
    Assets.xcassets
    Fonts.bundle/
      Kitab-Regular.ttf
      Kitab-Bold.ttf
    en.lproj/
      Localizable.strings
  appWidgetBundle.swift
  Info.plist
```

### Widget behavior

- **Tracker Widget** — small and medium. Reads the lightweight `WidgetContext` snapshot through `Storage`. Tapping a task invokes `ToggleTaskIntent`, which runs on the main actor and updates `TaskManager`.
- The snapshot records its `dayKey` and the task list as it will look after a reset (`resetUpcomingTasks`). Each timeline adds an entry at the next midnight, and a snapshot from an earlier day is shown as a fresh day, so the widget rolls over without the app running.
- `ToggleTaskIntent` throws instead of toggling when the store is not persistent, so a tap can never appear to work and then be lost.
- **Quick Surahs Widget** — medium only. Uses `AppIntentConfiguration` so users can choose up to three surahs from the native widget configuration UI. Deep links open the selected surah.
- Quick Surahs Arabic text uses the same Kitab font family as the app.
- `WidgetFontLoader` registers the widget’s font bundle at runtime.
- Widget gallery names, task counts, and configuration strings are localized in the widget’s own `Localizable.strings`.

### Target membership

All four targets use Xcode synchronized folders.

| Target | Folders | Deployment target |
|---|---|---|
| `simple-quran` | `simple-quran/` | iOS 17.0 |
| `app-widgetExtension` | `app-widget/` | iOS 18.4 |
| `simple-quranTests` | `simple-quranTests/` (hosted by the app) | iOS 17.0 |
| `app-widgetTests` | `app-widgetTests/` and `app-widget/` (no host) | iOS 18.4 |

Some `Core` files are intentionally shared with the widget to support task toggling and snapshot access. These files appear as shared-target items in Xcode:

- Tracker models, `Category`, `TaskDetails`, `SurahBookmark`, `NotificationIdentifier` and `WidgetContext`
- `TaskManager`, `HidayahStore`, and tracker history/notification services
- `Storage` and related identifiers

The shared files are listed in **two** exception sets on the `simple-quran` folder: one for `app-widgetExtension` and one for `app-widgetTests`, which compiles the same Core files. The two lists must stay identical; a file added to only one breaks the other target's build.

`app-widgetTests` excludes `appWidgetBundle.swift` (it has `@main`) and `Info.plist` from the `app-widget/` folder.

Do not manually add synchronized-folder files to target source phases. Add or remove membership through the synchronized-folder exceptions.

## Persistence

- SwiftData store in App Group container: `group.com.hasifofficial.simple-quran`.
- App Group `UserDefaults` for small preferences and the widget snapshot.
- Widget display data comes from the snapshot; widget task toggles use the shared tracker domain.
- No automatic destructive reset is allowed.
- Clearing tracker data requires an explicit user action.

### Schema versioning

The store opens with `HidayahSchemaV1` and `HidayahMigrationPlan` (both in `HidayahStore.swift`). Before changing any `@Model`:

1. Freeze the current version by nesting copies of the current models inside `HidayahSchemaV1`.
2. Add `HidayahSchemaV2` with the changed models.
3. Add a migration stage to `HidayahMigrationPlan`.

Changing a model without a new version makes the on-disk store fail to open.

### When the store cannot open

`HidayahStore` never replaces user data silently. If the on-disk store fails to open (for example a schema mismatch, or a missing App Group):

- The failure is logged and kept in `loadError`; `isPersistent` is `false`.
- The store runs in memory so the app stays usable, but nothing written survives a relaunch.
- Shared preferences (`trackerActiveDayKey`, `trackerStartDayKey`) and the widget snapshot are left untouched, so the data on disk stays authoritative.
- `AppController` reports the error to Crashlytics and shows the user an alert.
- `TaskManager.loadTasks()` calls `reconnectIfNeeded()`, so a temporary failure recovers on the next load or foreground.

## Localization

- App UI: `Resources/en.lproj/Localizable.strings`
- Widget UI: `app-widget/Resources/en.lproj/Localizable.strings`
- Never rely on the app’s localization bundle from inside the widget; each target has its own bundle.
- Use feature-prefixed keys (`setting_`, `tracker_`, `tasbih_`, `widget_`).
- Arabic Quran/dhikr content, user-created names, and numeric values are data, not UI chrome.
- Localize default category names when they are shown, not when they are saved. Day records store a copy of each task's category name, and a record saved from the widget holds the raw key; `TrackerDayDetailViewModel.categoryName(for:)` looks default names up from the category ID.

## Concurrency

The project builds in Swift 5 mode with `SWIFT_STRICT_CONCURRENCY = complete` and `SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES`. Production code has no concurrency warnings; keep it that way.

- UI state, the tracker domain and persistence are `@MainActor`: `TaskManager`, `HidayahStore`, `TrackerNotificationScheduler`, `SurahCatalog`, `AppController`, `AppRouter`, `DeeplinkManager` and every `@Observable` view model.
- Networking services are stateless and `Sendable`; requests and JSON decoding run off the main actor.
- Callbacks the system delivers on the main queue (`NotificationCenter` observers with `queue: .main`) use `MainActor.assumeIsolated`.
- `nonisolated(unsafe)` is allowed only with a comment explaining why it is safe.

## Dependency injection and testing

Shared instances (`TaskManager.shared`, `HidayahStore.shared`, `SurahCatalog.shared`, `TrackerNotificationScheduler.shared`) are defaults for production wiring only. New types take their dependencies through `init`, defaulting to the shared instance.

When the process hosts unit tests, `AppEnvironment.isRunningUnitTests` switches the shared instances to an in-memory store, a separate preferences suite and a separate catalog cache, so tests never touch real data.

### Test targets

- **`simple-quranTests`** — hosted by the app. Covers Core, navigation, view models and every screen. Screens are rendered with `ViewHost`, which shows a view in a real window and drives its controls through the accessibility tree.
- **`app-widgetTests`** — no host. Compiles the widget sources and the shared Core files directly, so widget code is in the test module without `@testable import`.

Both run from the `simple-quran` scheme (⌘U) with code coverage enabled.

### Test conventions

- Test files mirror the app's folder structure: the tests for `simple-quran/Core/Tracker/TaskManager.swift` are in `simple-quranTests/Core/Tracker/TaskManagerTests.swift`. Shared fakes and fixtures live in each target's `Support/` folder.
- XCTest, with names in the form `test_<subject>_should_<expectation>()`.
- Every test body has `// Arrange`, `// Act` and `// Assert` sections.
- Each test starts clean: a fresh in-memory store, `resetStorage()`, `StubURLProtocol.reset()` and a `TestClock` where dates matter.
- Run the suite on more than one iOS version before merging; some UIKit details (tab bars, SF Symbol accessibility labels) differ between releases.

## Privacy

Both the app and the widget ship a `PrivacyInfo.xcprivacy` at the root of their folder. They declare `UserDefaults` access with reason `1C8F.1` (data shared within the App Group), no tracking, and no data collected by the app's own code; Firebase declares its own collection in its SDK manifests.

When code starts using another required-reason API (file timestamps, system boot time, disk space, active keyboards), declare it in both manifests.

## Synchronized folders

The project uses Xcode synchronized folders.

- New files inside existing folders are picked up automatically.
- Do not add duplicate source references to `project.pbxproj`; doing so causes duplicate-build warnings.
- Moving a shared file that belongs to the widget requires updating both the `app-widgetExtension` and `app-widgetTests` membership exceptions.
- Resource bundles and localized files must remain inside the target that uses them.

## Adding a feature

1. Create `Features/<Feature>`.
2. Add the screen and a paired `@Observable` view model when it has state or derived data.
3. Put feature-only views in `Features/<Feature>/Components`.
4. Put cross-feature UI in `Shared/UI`.
5. Inject services from the composition root or parent screen.
6. Add localization keys under the feature prefix.
7. If the feature has a widget, add a dedicated folder under `app-widget/Widgets`.
8. If the feature shares a `Core` file with the widget, add it to both widget exception sets.
9. Add tests in the matching folder under `simple-quranTests/` (or `app-widgetTests/`).
10. If the feature uses a new required-reason API, declare it in the privacy manifests.
11. Build with a clean derived-data path and run the tests before merging.
