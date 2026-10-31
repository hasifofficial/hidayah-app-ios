# hidayah-app-ios

iOS app for Hidayah (Quran reader, bookmarks, tracker and widget).

## Dependencies

Dependencies are managed with Swift Package Manager. Open
`simple-quran.xcodeproj` in Xcode; packages are resolved automatically and the
resolved versions are committed in
`simple-quran.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

Remote packages:

- Firebase (`FirebaseAnalytics`, `FirebaseCrashlytics`, `FirebaseMessaging`, `FirebaseCore`)
- RxSwift / RxCocoa / RxDataSources
- Action
- Toast-Swift

`Shimmer` is vendored as a local Swift package in
[`Packages/Shimmer`](Packages/Shimmer/README.md) because the upstream fork does
not ship a `Package.swift`.

## Requirements

- Xcode 26 or newer (the project uses Firebase 13, which requires iOS 15+)
- iOS 15.0 deployment target

## Build

```sh
xcodebuild \
  -project simple-quran.xcodeproj \
  -scheme simple-quran \
  -destination 'generic/platform=iOS Simulator' \
  build
```
