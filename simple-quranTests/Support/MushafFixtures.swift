//
//  MushafFixtures.swift
//  simple-quranTests
//

import CoreGraphics
import Foundation
@testable import simple_quran

/// A loader serving a small made-up layout and blank page images, so tests
/// don't decode the bundled pages. Used only from the main actor.
final class FakeMushafLoader: MushafLoading, @unchecked Sendable {
    var layoutResult: Result<MushafLayout, MushafLoadError>
    private(set) var imageRequests: [Int] = []

    init(layout: MushafLayout = MushafFixtures.layout()) {
        layoutResult = .success(layout)
    }

    func layout() throws -> MushafLayout {
        try layoutResult.get()
    }

    func pageImage(_ page: Int, maxPixelWidth: CGFloat) -> CGImage? {
        imageRequests.append(page)
        return MushafFixtures.blankImage(width: Int(maxPixelWidth))
    }
}

enum MushafFixtures {
    /// Four pages: 1:1, 2:1, 2:6 and 3:1, with juz 2 starting at 2:6. Every
    /// other surah starts on page 4.
    static func layout() -> MushafLayout {
        MushafLayout(
            pageCount: 4,
            surahStartPages: [1, 2, 4] + Array(repeating: 4, count: 111),
            pageStarts: [
                .init(surah: 1, ayah: 1),
                .init(surah: 2, ayah: 1),
                .init(surah: 2, ayah: 6),
                .init(surah: 3, ayah: 1)
            ],
            juzStarts: [
                .init(surah: 1, ayah: 1),
                .init(surah: 2, ayah: 6)
            ]
        )
    }

    static func blankImage(width: Int, height: Int = 10) -> CGImage? {
        CGContext(
            data: nil,
            width: max(width, 1),
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )?.makeImage()
    }
}
