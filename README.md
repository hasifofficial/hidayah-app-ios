# hidayah-app-ios

iOS app for Hidayah (Quran reader, bookmarks, Tasbih, Al-Mathurat, tracker and widget).

## Dependencies

Dependencies are managed with Swift Package Manager. Open
`hidayah-app.xcodeproj` in Xcode; packages are resolved automatically and the
resolved versions are committed in
`hidayah-app.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

Remote packages:

- Firebase (`FirebaseCore`, `FirebaseCrashlytics`)

## Requirements

- Xcode 26 or newer
- iOS 17.0 deployment target (the app uses SwiftUI Observation)

## Build

```sh
xcodebuild \
  -project hidayah-app.xcodeproj \
  -scheme hidayah-app \
  -destination 'generic/platform=iOS Simulator' \
  build
```
