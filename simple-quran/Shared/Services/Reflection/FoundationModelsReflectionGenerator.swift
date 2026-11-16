//
//  FoundationModelsReflectionGenerator.swift
//  simple-quran
//

#if canImport(FoundationModels)
import Foundation
import FoundationModels
import os

/// Writes tracker reflections with Apple's on-device language model.
@available(iOS 26.0, *)
struct FoundationModelsReflectionGenerator: TrackerReflectionGenerating {
    @Generable
    struct Reflection {
        @Guide(description: "One warm sentence of at most 20 words that uses only the given facts.")
        var message: String
    }

    private static let logger = Logger(subsystem: "Hidayah", category: "Reflection")

    var isAvailable: Bool {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
            Self.logger.info("On-device model unavailable: \(String(describing: model.availability), privacy: .public)")
            return false
        }
        guard model.supportsLocale() else {
            Self.logger.info("On-device model doesn't support locale \(Locale.current.identifier, privacy: .public)")
            return false
        }
        return true
    }

    func reflection(for snapshot: TrackerSnapshot) async throws -> String {
        let session = LanguageModelSession(instructions: TrackerReflection.instructions)
        do {
            let response = try await session.respond(
                to: TrackerReflection.prompt(for: snapshot),
                generating: Reflection.self,
                options: GenerationOptions(temperature: 0.7)
            )
            return response.content.message
        } catch {
            Self.logger.error("Reflection failed: \(String(describing: error), privacy: .public)")
            throw error
        }
    }
}
#endif
