# hidayah-app-ios

iOS app for Hidayah (Quran reader, bookmarks, tracker and widget).

## Dependencies

Dependencies are managed with Swift Package Manager. Open
`simple-quran.xcodeproj` in Xcode; packages are resolved automatically and the
resolved versions are committed in
`simple-quran.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

Remote packages:

- Firebase (`FirebaseCore`, `FirebaseCrashlytics`)

## Requirements

- Xcode 26 or newer
- iOS 17.0 deployment target (the app uses SwiftUI Observation)

## Build

```sh
xcodebuild \
  -project simple-quran.xcodeproj \
  -scheme simple-quran \
  -destination 'generic/platform=iOS Simulator' \
  build
```
