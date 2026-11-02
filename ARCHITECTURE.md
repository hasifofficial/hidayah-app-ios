# Hidayah Architecture

## Layers

```
simple-quran/
  App/          App lifecycle, composition root, routing, deep links
  Core/         Models, networking, persistence, tracker domain services
  Features/     Feature screens and their view models
  Shared/       Reusable UI components, form controls, modifiers, services
  Resources/    Assets, fonts, localization, constants
```

## MVVM conventions

- **View** — SwiftUI layout and user interaction only.
- **ViewModel** — `@Observable` state, validation, formatting, and feature actions.
- **Domain/service** — `TaskManager`, `HidayahStore`, `SurahService`, notification scheduling.
- **Composition root** — `AppController` wires services; `RootView` owns tab/navigation state.

Feature view models should not construct network or persistence clients directly. They receive existing services or use the shared domain layer.

## Features

```
Features/
  Quran/{List,Detail,Bookmarks,Settings,Components}
  Search/
  Settings/
  Tracker/{Home,Calendar,DayDetail,Levels,Achievements,TaskEditor,Settings,Components}
  Tasbih/{,Components}
```

## Shared UI

- `AppFormHeader`, `AppFormCard`, `AppTextField`, `AppIconPicker`, `AppPrimaryButton`
- `SettingsActionRow`, `SettingsSectionHeader`, `SettingsToggleRow`
- `SurahListRowView`, `TrackerSummaryCardView`, `TrackerCategoryCardView`, `TrackerTaskRowView`
- `TasbihBeadProgressView`
- Loading placeholders, shimmer, load animation, mail/Safari representables

Components are named by responsibility, not by the first screen that used them.

## Persistence

- SwiftData in the App Group for tracker and bookmark data.
- App Group `UserDefaults` for small preferences and the widget snapshot.
- The widget reads only a lightweight snapshot.
- No automatic destructive reset is allowed; clearing user data requires an explicit user action.

## Adding a feature

1. Create `Features/<Feature>`.
2. Add a View and an `@Observable` ViewModel.
3. Put shared UI in `Shared/UI`; keep feature-only components in `Features/<Feature>/Components`.
4. Inject services from the composition root.
5. Add localization keys under the feature prefix.
6. Build without warnings before merging.
