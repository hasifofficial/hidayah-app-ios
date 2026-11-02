//
//  SettingViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation
import Combine
import Observation

enum SettingsSelection: String, Identifiable {
    case recitation
    case translation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recitation:
            return NSLocalizedString(
                "surah_recitation_drawer_title",
                comment: ""
            )
        case .translation:
            return NSLocalizedString(
                "surah_translation_drawer_title",
                comment: ""
            )
        }
    }
}

@Observable
final class SettingsViewModel {
    private(set) var recitationItems: [ItemSelector] = []
    private(set) var translationItems: [ItemSelector] = []
    private(set) var selectedRecitationName: String
    private(set) var selectedTranslationName: String
    private(set) var selectedRecitationValue: String?
    private(set) var selectedTranslationValue: String?
    var allowKahfReminder: Bool
    var allowTrackerCheerleader: Bool

    @ObservationIgnored
    var onError: ((String) -> Void)?

    @ObservationIgnored
    private let surahService: SurahService

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var hasLoadedEditions = false

    init(surahService: SurahService) {
        self.surahService = surahService

        let recitation: EditionResponse? = Storage.loadObject(
            key: .selectedRecitation
        )
        let translation: EditionResponse? = Storage.loadObject(
            key: .selectedTranslation
        )

        let recitationName = recitation?.englishName ?? "Alafasy"
        selectedRecitationName = recitationName
        selectedRecitationValue = recitation?.identifier

        let translationLanguage = Constants.getLanguageFromCode(
            code: translation?.language ?? ""
        )
        selectedTranslationName = translation == nil
            ? "English"
            : translationLanguage

        selectedTranslationValue = translation?.identifier

        allowKahfReminder = Storage.load(key: .allowKahfReminder) as? Bool ?? true
        allowTrackerCheerleader = Storage.load(key: .allowTrackerCheerleader) as? Bool ?? true
    }

    var versionText: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        return String(
            format: NSLocalizedString(
                "setting_app_verison",
                comment: ""
            ),
            appVersion,
            buildNumber
        )
    }

    func loadEditionsIfNeeded() {
        guard !hasLoadedEditions else { return }

        hasLoadedEditions = true
        loadEditions()
    }

    func loadEditions() {
        surahService.getSurahEdition()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

                if case .failure(let error) = result {
                    self.onError?(
                        (error as? RequestError)?.message
                            ?? error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] edition in
                self?.handleEditionSuccess(edition)
            }
            .store(in: &cancellables)
    }

    func items(for selection: SettingsSelection) -> [ItemSelector] {
        switch selection {
        case .recitation:
            return recitationItems
        case .translation:
            return translationItems
        }
    }

    func selectedValue(for selection: SettingsSelection) -> String? {
        switch selection {
        case .recitation:
            return selectedRecitationValue
        case .translation:
            return selectedTranslationValue
        }
    }

    func select(_ item: ItemSelector, for selection: SettingsSelection) {
        switch selection {
        case .recitation:
            selectRecitation(item)
        case .translation:
            selectTranslation(item)
        }
    }

    func setKahfReminder(_ value: Bool) {
        allowKahfReminder = value
        Storage.save(.allowKahfReminder, value)
    }

    func setTrackerCheerleader(_ value: Bool) {
        allowTrackerCheerleader = value
        Storage.save(.allowTrackerCheerleader, value)
        TrackerNotificationScheduler.shared.syncDailyCheer()
    }

    private func handleEditionSuccess(_ edition: Edition) {
        guard let editions = edition.data else { return }

        let recitationEditions = editions.filter {
            $0.format == .audio
                && $0.language == "ar"
                && $0.type == "versebyverse"
        }

        recitationItems = recitationEditions.map {
            ItemSelector(
                title: $0.englishName ?? "",
                value: $0.identifier ?? "",
                item: $0
            )
        }

        if selectedRecitationValue == nil {
            selectedRecitationValue = recitationItems.first(where: {
                $0.title == selectedRecitationName
            })?.value
        }

        translationItems = editions
            .filter {
                $0.format == .text && $0.type == "translation"
            }
            .map {
                let language = Constants.getLanguageFromCode(
                    code: $0.language ?? ""
                )
                return ItemSelector(
                    title: "\(language) - \($0.name ?? "")",
                    value: $0.identifier ?? "",
                    item: $0
                )
            }
    }

    private func selectRecitation(_ item: ItemSelector) {
        guard let recitation = item.item as? EditionResponse,
              let qariName = recitation.englishName else { return }

        do {
            try save(recitation, key: .selectedRecitation)
            selectedRecitationName = qariName
            selectedRecitationValue = recitation.identifier
        } catch {
            onError?(error.localizedDescription)
        }
    }

    private func selectTranslation(_ item: ItemSelector) {
        guard let translation = item.item as? EditionResponse,
              let language = translation.language else { return }

        do {
            try save(translation, key: .selectedTranslation)
            selectedTranslationName = Constants.getLanguageFromCode(
                code: language
            )
            selectedTranslationValue = translation.identifier
        } catch {
            onError?(error.localizedDescription)
        }
    }

    private func save(
        _ edition: EditionResponse,
        key: Storage.StorageKey
    ) throws {
        Storage.delete(key)
        let data = try JSONEncoder().encode(edition)
        Storage.save(key, data)
    }
}
