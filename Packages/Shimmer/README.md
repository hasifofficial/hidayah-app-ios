# Shimmer (local Swift package)

This package vendors the Objective-C `Shimmer` sources used by the app so the
dependency can be consumed through Swift Package Manager.

- Upstream project: https://github.com/facebook/Shimmer
- Source fork: https://github.com/hasifofficial/Shimmer
- Vendored commit: `07aa5e563c2ef8663dab220c925a5c5abfecc0c3` (version 1.0.2)

The fork does not ship a `Package.swift`, so the source files are kept here and
exposed as the `Shimmer` library product. `FBShimmeringView` and
`FBShimmeringLayer` are imported into the app with `import Shimmer`.
