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
hidayah-app/
  App/          Lifecycle, composition root, navigation, deep links
  Core/         Models, networking, persistence, tracker domain services
  Features/     Feature screens, view models, and feature components
  Shared/       Cross-feature UI, form controls, modifiers, services
  Resources/    Assets, fonts, localization, constants, bundled Al-Mathurat text and Mushaf pages

hidayah-app-widget/         Widget extension
hidayah-app-watch/          Apple Watch app
hidayah-app-tests/          Unit tests for the app, mirroring hidayah-app/
hidayah-app-widget-tests/   Unit tests for the widget, mirroring hidayah-app-widget/
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
  Lifecycle/    AppController, AppDelegate, HidayahApp
  Navigation/   AppRouter, DeeplinkManager
  Root/         RootView
  Base.lproj/   LaunchScreen.storyboard
```

- `AppController` is the composition root for services and shared state. Its initializer takes the task manager, store, notification scheduler and notification center, defaulting to the shared instances.
- `RootView` owns tab and split-view navigation.
- `AppRouter` owns tab selection, navigation paths, and sheet state.
- `DeeplinkManager` maps URLs to router destinations. Links use `hidayahapp://inAppDeeplink/` followed by `quran[/<surah>[/<ayah>]]`, `bookmark`, `tracker`, `mathurat[/<order>]` or `qibla` (opens Home › Explore › Qibla).

## Core

```
Core/
  Models/        Mathurat, Quran, Tracker and Widget models
  Networking/    Base, Endpoints, Services
  Persistence/   HidayahStore, Storage
  Tracker/       TaskManager, TrackerHistoryEngine, TrackerNotificationScheduler
  Mathurat/      MathuratLibrary
  Mushaf/        MushafLibrary
  Extensions/
```

- `TaskManager` is the tracker domain facade. It takes its store, notification scheduler and clock (`now: () -> Date`) through `init`.
- `HidayahStore` owns SwiftData persistence, including the schema version and migration plan (see Persistence).
- `Storage` owns App Group `UserDefaults` access and the widget snapshot.
- `TrackerNotificationScheduler` posts tracker reminders through the `NotificationScheduling` protocol, which `UNUserNotificationCenter` conforms to.
- `APIClientService` and `SurahService` are stateless and `Sendable`, and use `async`/`await`. `APIClientService` takes its `URLSession` through `init`.
- `SurahCatalog` caches the surah list on disk; its cache location is injectable.
- `BundleMathuratLoader` (behind `MathuratLoading`) and `BundleMushafLoader` (behind `MushafLoading`) read the bundled content; their directories are injectable.
- Models are plain value/reference types with no SwiftUI dependencies.

## Features

One folder per feature: `Home`, `Explore`, `Quran`, `Reading`, `Mathurat`, `Tasbih`, `Qibla`, `Tracker`, `Search`, `Settings` and `WhatsNew`. Larger features split into sub-folders by screen (for example `Quran/List`, `Quran/Mushaf`, `Tracker/Calendar`), each with its own `Components/` where needed.

### MVVM rules

- **View** — layout, bindings, animations, and navigation callbacks only.
- **ViewModel** — `@Observable` state, derived data, validation, formatting, and feature actions.
- **Shared domain service** — injected into the view model; not created by the view.
- A screen with meaningful state or derived data gets a paired `ViewModel`.
- Feature-only components live in the feature’s `Components/` folder.
- Cross-feature components live in `Shared/UI`.

Examples:

- `TasbihView` owns animation/gesture presentation; `TasbihViewModel` owns counting, phrase state, and completion flow.
- `WidgetGuideView` owns presentation; `WidgetGuideViewModel` owns selection and tracker-derived preview data.
- State that must survive tab switches (for example `MathuratViewModel`) is held in `@State` by `RootView`.

## Shared

```
Shared/
  Services/          AppHaptics, Reflection
  UI/
    Background/      App background gradient
    Cards/           Feature cards and icons
    Components/      Settings rows and headers
    Forms/           Form controls, SelectionView, ReadingSettingsView
    Loading/         Loading placeholders
    Modifiers/       View modifiers, such as the load animation
    Reader/          Building blocks shared by the Quran reader and Al-Mathurat
    Representables/  UIKit wrappers (MailView, SafariView)
```

Naming rule: name components by responsibility, not by the first screen that used them.

## Widget extension

```
hidayah-app-widget/
  AppIntents/      ToggleTaskIntent
  Widgets/
    Tracker/       Tracker widget, provider and view
    QuickSurah/    Quick Surahs widget, configuration intent, provider and view
  Shared/          WidgetFontLoader
  Resources/       Assets, Fonts.bundle, en.lproj/Localizable.strings
  HidayahAppWidgetBundle.swift
  Info.plist
```

- **Tracker widget** reads the lightweight `WidgetContext` snapshot through `Storage`. Tapping a task invokes `ToggleTaskIntent`, which runs on the main actor and updates `TaskManager`.
- The snapshot records its `dayKey` and the task list as it will look after a reset (`resetUpcomingTasks`). Each timeline adds an entry at the next tracker day start, and a snapshot from an earlier day is shown as a fresh day, so the widget rolls over without the app running.
- `ToggleTaskIntent` throws instead of toggling when the store is not persistent, so a tap can never appear to work and then be lost.
- **Quick Surahs widget** uses `AppIntentConfiguration` so users choose surahs in the system's widget configuration UI.
- `WidgetFontLoader` registers the widget’s own font bundle at runtime.

## Watch app

```
hidayah-app-watch/
  Sync/        WatchTrackerModel (WatchConnectivity on the Watch)
  Tracker/     Today's tasks
  Tasbih/      Counter with tap and Digital Crown
  Qibla/       Compass
  Resources/   Assets, Fonts.bundle (Amiri Bold only), en.lproj/Localizable.strings
  HidayahWatchApp.swift
  WatchRootView.swift
  PrivacyInfo.xcprivacy
```

A companion watchOS app (`com.hasifofficial.simple-quran.watchkitapp`) embedded in the iPhone app by the **Embed Watch Content** phase. It needs the iPhone app (`WKRunsIndependentlyOfCompanionApp = NO`) and has three screens: Istiqamah tracker, Tasbih and Qibla.

### Tracker sync

The iPhone owns the tracker. The Watch has no store; it shows a snapshot and asks the iPhone for changes over WatchConnectivity.

- **`WatchTrackerSnapshot`** (`Core/Watch/`) — today's day key and tasks, the current streak and level, and when the next tracker day starts and ends, so the Watch can show a fresh day before it hears from the iPhone. Past the end of the following day the Watch is *stale*: it shows the tasks but disables them until the iPhone sends a new snapshot.
- **`WatchTaskCompletion`** — a request to set (not toggle) one task's completion for a given day key, so a request delivered twice changes nothing.
- **`WatchSyncService`** (`Core/Watch/`, iPhone only) — `AppController` starts it with the `TaskManager`. It sets `TaskManager.onTrackerChange`, which runs on every widget refresh, and sends the snapshot with `updateApplicationContext` (plus a live message when the Watch is reachable). Completions from the Watch go through `TaskManager.setTaskCompletion(taskID:isCompleted:dayKey:)`, which ignores another day or a missing task; a request that changes nothing is answered with a fresh snapshot so the Watch drops it. In unit tests the shared instance has no session.
- **`WatchTrackerState`** (`Core/Watch/`) — plain value logic for what the Watch shows: the snapshot with unanswered taps laid on top. Each tap records when it was sent, and each snapshot when it was made (`generatedAt`). A snapshot settles a tap when it already reflects it, was made after the tap was sent (the iPhone has seen it, whether or not it applied it), or has moved past the tap's day, so a tap the iPhone rejected never lingers. It takes `now` as a parameter and is tested in `hidayah-app-tests`.
- **`WatchTrackerModel`** (Watch only) — keeps the `WatchTrackerState` in the Watch's `UserDefaults` so it shows on launch, and asks for a snapshot when the app becomes active. When the iPhone is reachable it sends a tap with `sendMessage` and a reply handler; the iPhone answers with the new snapshot, which settles the tap at once, and any send error falls back to `transferUserInfo`. Otherwise it uses `transferUserInfo` straight away (queued until the iPhone app runs).
- `WatchSyncService` implements both `session(_:didReceiveMessage:)` variants. A message sent without a reply handler only reaches the variant without one, and WatchConnectivity drops it silently when that method is missing.

Adding and editing tasks stays on the iPhone.

### Tasbih and Qibla

Both reuse the iPhone view models: `TasbihViewModel` (tap anywhere or turn the Digital Crown; turning back undoes) and `QiblaViewModel` with `CoreLocationQiblaSensor`. Only the views are Watch-specific. `AppHaptics` plays `WKHapticType`s on watchOS, and `QiblaSensor` leaves out the iOS-only heading orientation and calibration callback. Watches without a compass get the "No Compass" screen.

### Target membership

All five targets use Xcode synchronized folders.

| Target | Folders | Deployment target |
|---|---|---|
| `hidayah-app` | `hidayah-app/` | iOS 17.0 |
| `hidayah-app-widget` | `hidayah-app-widget/` | iOS 18.4 |
| `hidayah-app-tests` | `hidayah-app-tests/` (hosted by the app) | iOS 17.0 |
| `hidayah-app-widget-tests` | `hidayah-app-widget-tests/` and `hidayah-app-widget/` (no host) | iOS 18.4 |
| `hidayah-app-watch` | `hidayah-app-watch/` | watchOS 10.0 |

Targets, folders and schemes share the `hidayah-app` names, and the project is `hidayah-app.xcodeproj`. The app's Swift module is `hidayah_app` (`@testable import hidayah_app`). Bundle IDs, the App Group and notification identifiers keep their original `simple-quran` form, because they identify the app to the App Store and on users' devices.

The widget target keeps its original product and module name, `app-widgetExtension` (`PRODUCT_NAME` and `PRODUCT_MODULE_NAME` are set explicitly). Users' configured Quick Surahs widgets store an App Intent that may be identified by that module, so renaming it could reset their choices. Leave both alone.

Some `Core` files are shared with the widget to support task toggling and snapshot access:

- Tracker models, `Category`, `TaskDetails`, `SurahBookmark`, `NotificationIdentifier` and `WidgetContext`
- `TaskManager`, `HidayahStore`, and tracker history/notification services
- `Storage` and related identifiers

The shared files are listed in **two** exception sets on the `hidayah-app` folder: one for `hidayah-app-widget` and one for `hidayah-app-widget-tests`, which compiles the same Core files. The two lists must stay identical; a file added to only one breaks the other target's build.

`hidayah-app-watch` has its own exception set on the `hidayah-app` folder listing the files it compiles: `Font+Extensions` (for Amiri Bold, loaded from the Watch's own `Resources/Fonts.bundle`, which holds only that font), `Category`, `TaskDetails`, `QiblaMath`, `QiblaSensor`, `WatchTrackerSnapshot`, `WatchTrackerState`, `QiblaViewModel`, `TasbihViewModel` and `AppHaptics`. Anything added to that list must build for watchOS (no UIKit, SwiftData or WidgetKit). `WatchSyncService` is iPhone only and stays out of it.

`hidayah-app-widget-tests` excludes `HidayahAppWidgetBundle.swift` (it has `@main`) and `Info.plist` from the `hidayah-app-widget/` folder.

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

## Bundled content

- `Resources/Mathurat.bundle/sughra.json` — Al-Mathurat Sughra: Arabic text, Malay translation, title, repeat count, and whether each entry is read in the morning, evening or both. Edit it by hand and run `MathuratLibraryTests`, which guard against accidental edits.
- `Resources/Mushaf.bundle/` — the 604 Madani Mushaf page images and `pages.json`, which maps surahs, ayahs, juz and quarter hizb to pages. `MushafLayoutTests` and `MushafLibraryTests` check the layout against known pages.

## Localization

- App UI: `hidayah-app/Resources/en.lproj/Localizable.strings`
- Widget UI: `hidayah-app-widget/Resources/en.lproj/Localizable.strings`
- Watch UI: `hidayah-app-watch/Resources/en.lproj/Localizable.strings`. It repeats the keys the shared view models and default category names use (`tasbih_`, `qibla_`, `default_category_`); keep their text the same as the app's.
- Never rely on the app’s localization bundle from inside the widget or the Watch app; each target has its own bundle.
- Use feature-prefixed keys (`setting_`, `tracker_`, `tasbih_`, `mathurat_`, `widget_`, `watch_`).
- Arabic Quran/dhikr content, user-created names, and numeric values are data, not UI chrome.
- Localize default category names when they are shown, not when they are saved. Day records keep the category name as it was saved (a record saved from the widget holds the raw key), so look default names up from the category ID.

## Concurrency

The project builds in Swift 5 mode with `SWIFT_STRICT_CONCURRENCY = complete` and `SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES`. Production code has no concurrency warnings; keep it that way.

- UI state, the tracker domain and persistence are `@MainActor`: `TaskManager`, `HidayahStore`, `TrackerNotificationScheduler`, `SurahCatalog`, `AppController`, `AppRouter`, `DeeplinkManager` and every `@Observable` view model.
- Content loaders and networking services are `Sendable`; requests, JSON decoding and image decoding run off the main actor.
- Callbacks the system delivers on the main queue (`NotificationCenter` observers with `queue: .main`) use `MainActor.assumeIsolated`.
- `nonisolated(unsafe)` is allowed only with a comment explaining why it is safe.

## Dependency injection and testing

Shared instances (`TaskManager.shared`, `HidayahStore.shared`, `SurahCatalog.shared`, `TrackerNotificationScheduler.shared`) are defaults for production wiring only. New types take their dependencies through `init`, defaulting to the shared instance.

When the process hosts unit tests, `AppEnvironment.isRunningUnitTests` switches the shared instances to an in-memory store, a separate preferences suite and a separate catalog cache, so tests never touch real data.

### Test targets

- **`hidayah-app-tests`** — hosted by the app. Covers Core, navigation, view models and every screen. Screens are rendered with `ViewHost`, which shows a view in a real window and drives its controls through the accessibility tree.
- **`hidayah-app-widget-tests`** — no host. Compiles the widget sources and the shared Core files directly, so widget code is in the test module without `@testable import`.
- The Watch app has no test target. Its logic lives in shared `Core/Watch` files tested in `hidayah-app-tests/Core/Watch/`; keep Watch-only files to views and WatchConnectivity plumbing.

Both run from the `hidayah-app` scheme (⌘U) with code coverage enabled.

### Test conventions

- Test files mirror the app's folder structure: the tests for `hidayah-app/Core/Tracker/TaskManager.swift` are in `hidayah-app-tests/Core/Tracker/TaskManagerTests.swift`. Shared fakes and fixtures live in each target's `Support/` folder.
- XCTest, with names in the form `test_<subject>_should_<expectation>()`.
- Every test body has `// Arrange`, `// Act` and `// Assert` sections.
- Each test starts clean: a fresh in-memory store, `resetStorage()`, `StubURLProtocol.reset()` and a `TestClock` where dates matter.
- Run the suite on more than one iOS version before merging; some UIKit details (tab bars, SF Symbol accessibility labels) differ between releases.

## Privacy

The app, the widget and the Watch app each ship a `PrivacyInfo.xcprivacy` at the root of their folder. The app and widget declare `UserDefaults` access with reason `1C8F.1` (data shared within the App Group); the Watch app uses its own defaults and declares `CA92.1`. None track or collect data in their own code; Firebase declares its own collection in its SDK manifests.

When code starts using another required-reason API (file timestamps, system boot time, disk space, active keyboards), declare it in every manifest whose target uses it.

## Synchronized folders

- New files inside existing folders are picked up automatically.
- Do not add source references to `project.pbxproj` by hand; doing so causes duplicate-build warnings. Change membership through the synchronized-folder exceptions.
- Moving a shared file that belongs to the widget requires updating both the `hidayah-app-widget` and `hidayah-app-widget-tests` membership exceptions.
- Resource bundles and localized files must remain inside the target that uses them.

## Adding a feature

1. Create `Features/<Feature>`.
2. Add the screen and a paired `@Observable` view model when it has state or derived data.
3. Put feature-only views in `Features/<Feature>/Components`.
4. Put cross-feature UI in `Shared/UI`.
5. Inject services from the composition root or parent screen.
6. Add localization keys under the feature prefix.
7. If the feature has a widget, add a dedicated folder under `hidayah-app-widget/Widgets`.
8. If the feature shares a `Core` file with the widget, add it to both widget exception sets. If it comes to the Watch, add the shared files to the `hidayah-app-watch` exception set and the Watch view under `hidayah-app-watch/`.
9. Add tests in the matching folder under `hidayah-app-tests/` (or `hidayah-app-widget-tests/`).
10. If the feature uses a new required-reason API, declare it in the privacy manifests.
11. Build with a clean derived-data path and run the tests before merging.
