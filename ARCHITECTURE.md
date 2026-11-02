# Hidayah Architecture

## Goals

- Feature-based structure with clear dependency direction.
- MVVM for feature screens.
- Shared services and UI only when genuinely reusable.
- No direct construction of networking or persistence clients inside views.
- Widget support without duplicating app-specific UI code.

## Layers

```
simple-quran/
  App/          Lifecycle, composition root, navigation, deep links
  Core/         Models, networking, persistence, tracker domain services
  Features/     Feature screens, view models, and feature components
  Shared/       Cross-feature UI, form controls, modifiers, services
  Resources/    Assets, fonts, localization, constants
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

- `AppController` is the composition root for services and shared state.
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

- `TaskManager` is the tracker domain facade.
- `HidayahStore` owns SwiftData persistence.
- `Storage` owns App Group `UserDefaults` access and the widget snapshot.
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

- **Tracker Widget** — small and medium. Reads the lightweight `WidgetContext` snapshot through `Storage`. Tapping a task invokes `ToggleTaskIntent`, which updates `TaskManager`.
- **Quick Surahs Widget** — medium only. Uses `AppIntentConfiguration` so users can choose up to three surahs from the native widget configuration UI. Deep links open the selected surah.
- Quick Surahs Arabic text uses the same Kitab font family as the app.
- `WidgetFontLoader` registers the widget’s font bundle at runtime.
- Widget gallery names, task counts, and configuration strings are localized in the widget’s own `Localizable.strings`.

### Target membership

The main app target and widget extension use Xcode synchronized folders.

Some `Core` files are intentionally shared with the widget target to support task toggling and snapshot access. These files appear as shared-target items in Xcode:

- Tracker models and `WidgetContext`
- `TaskManager`, `HidayahStore`, and tracker history/notification services
- `Storage` and related identifiers

Do not manually add synchronized-folder files to target source phases. Add or remove membership through the widget target’s synchronized-folder exceptions.

## Persistence

- SwiftData store in App Group container: `group.com.hasifofficial.simple-quran`.
- App Group `UserDefaults` for small preferences and the widget snapshot.
- Widget display data comes from the snapshot; widget task toggles use the shared tracker domain.
- No automatic destructive reset is allowed.
- Clearing tracker data requires an explicit user action.

## Localization

- App UI: `Resources/en.lproj/Localizable.strings`
- Widget UI: `app-widget/Resources/en.lproj/Localizable.strings`
- Never rely on the app’s localization bundle from inside the widget; each target has its own bundle.
- Use feature-prefixed keys (`setting_`, `tracker_`, `tasbih_`, `widget_`).
- Arabic Quran/dhikr content, user-created names, and numeric values are data, not UI chrome.

## Synchronized folders

The project uses Xcode synchronized folders.

- New files inside existing folders are picked up automatically.
- Do not add duplicate source references to `project.pbxproj`; doing so causes duplicate-build warnings.
- Moving a shared file that belongs to the widget requires updating the widget target’s membership exceptions.
- Resource bundles and localized files must remain inside the target that uses them.

## Adding a feature

1. Create `Features/<Feature>`.
2. Add the screen and a paired `@Observable` view model when it has state or derived data.
3. Put feature-only views in `Features/<Feature>/Components`.
4. Put cross-feature UI in `Shared/UI`.
5. Inject services from the composition root or parent screen.
6. Add localization keys under the feature prefix.
7. If the feature has a widget, add a dedicated folder under `app-widget/Widgets`.
8. Build with a clean derived-data path before merging.
