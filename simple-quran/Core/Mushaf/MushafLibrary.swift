//
//  MushafLibrary.swift
//  simple-quran
//

import CoreGraphics
import Foundation
import ImageIO
import OSLog

enum MushafLoadError: Error, Equatable {
    case missingResource
    case corrupt
}

protocol MushafLoading: Sendable {
    func layout() throws -> MushafLayout

    /// The page image decoded no wider than `maxPixelWidth`, or nil when it
    /// is missing or unreadable.
    func pageImage(_ page: Int, maxPixelWidth: CGFloat) -> CGImage?
}

/// Reads the bundled Mushaf pages and their layout from `Mushaf.bundle`.
struct BundleMushafLoader: MushafLoading {
    static let layoutFileName = "pages.json"

    private let directory: URL?

    private static let logger = Logger(
        subsystem: "com.hasifofficial.simple-quran",
        category: "Mushaf"
    )

    init(
        directory: URL? = Bundle.main.url(
            forResource: "Mushaf",
            withExtension: "bundle"
        )
    ) {
        self.directory = directory
    }

    /// The blank border trimmed from every page, as fractions of the
    /// 1920×3106 image. The same crop for all pages keeps the text the same
    /// size from page to page; across all 604 pages the text spans x 26–1894
    /// and y 14–3066.
    static let trim = (left: 20.0 / 1920, right: 20.0 / 1920, top: 8.0 / 3106, bottom: 34.0 / 3106)

    static func imageName(for page: Int) -> String {
        String(format: "page%03d.png", page)
    }

    func layout() throws -> MushafLayout {
        guard let url = directory?.appendingPathComponent(Self.layoutFileName),
              let data = try? Data(contentsOf: url) else {
            Self.logger.error("Missing Mushaf layout file")
            throw MushafLoadError.missingResource
        }

        do {
            return try JSONDecoder()
                .decode(MushafLayoutDTO.self, from: data)
                .layout()
        } catch {
            Self.logger.error(
                "Corrupt Mushaf layout file: \(String(describing: error), privacy: .public)"
            )
            throw MushafLoadError.corrupt
        }
    }

    /// Decodes straight to the requested width, so a 1920-pixel page never
    /// sits in memory at full size, then trims the blank border so the text
    /// fills that width.
    func pageImage(_ page: Int, maxPixelWidth: CGFloat) -> CGImage? {
        guard let url = directory?.appendingPathComponent(Self.imageName(for: page)),
              let source = CGImageSourceCreateWithURL(
                url as CFURL,
                [kCGImageSourceShouldCache: false] as CFDictionary
              ),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
              width > 0 else {
            Self.logger.error("Missing Mushaf page \(page)")
            return nil
        }

        let keptWidth = 1 - Self.trim.left - Self.trim.right
        let scale = min(max(maxPixelWidth, 1) / (width * keptWidth), 1)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(width, height) * scale
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(
            source, 0, options as CFDictionary
        ) else { return nil }

        let decodedWidth = CGFloat(image.width)
        let decodedHeight = CGFloat(image.height)
        let crop = CGRect(
            x: decodedWidth * Self.trim.left,
            y: decodedHeight * Self.trim.top,
            width: decodedWidth * keptWidth,
            height: decodedHeight * (1 - Self.trim.top - Self.trim.bottom)
        ).integral
        return image.cropping(to: crop) ?? image
    }
}
