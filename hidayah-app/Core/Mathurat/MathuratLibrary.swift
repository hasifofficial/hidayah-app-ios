//
//  MathuratLibrary.swift
//  simple-quran
//

import Foundation
import OSLog

enum MathuratLoadError: Error, Equatable {
    case missingResource
    case corrupt
}

protocol MathuratLoading: Sendable {
    /// The entries read at `time`, in reading order.
    func entries(for time: MathuratTime) throws -> [MathuratEntry]
}

/// Reads the bundled Al-Mathurat Sughra from `Mathurat.bundle/sughra.json`.
struct BundleMathuratLoader: MathuratLoading {
    static let fileName = "sughra.json"

    private let directory: URL?

    private static let logger = Logger(
        subsystem: "com.hasifofficial.simple-quran",
        category: "Mathurat"
    )

    init(
        directory: URL? = Bundle.main.url(
            forResource: "Mathurat",
            withExtension: "bundle"
        )
    ) {
        self.directory = directory
    }

    func entries(for time: MathuratTime) throws -> [MathuratEntry] {
        guard let url = directory?.appendingPathComponent(Self.fileName),
              let data = try? Data(contentsOf: url) else {
            Self.logger.error("Missing Al-Mathurat file")
            throw MathuratLoadError.missingResource
        }

        do {
            return try JSONDecoder()
                .decode(MathuratFileDTO.self, from: data)
                .entries(for: time)
        } catch {
            Self.logger.error(
                "Corrupt Al-Mathurat file: \(String(describing: error), privacy: .public)"
            )
            throw MathuratLoadError.corrupt
        }
    }
}
