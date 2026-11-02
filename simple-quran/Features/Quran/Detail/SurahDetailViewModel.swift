//
//  SurahDetailViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Combine
import AVFoundation
import Observation

struct SurahDetailAyah: Identifiable {
    let id: Int
    let numberInSurah: Int
    let arabic: String
    let translation: String
    let audioURL: URL?
    let translationIsRTL: Bool
}

@Observable
final class SurahDetailViewModel {
    var title: String = ""
    var selectedSurahNo: Int?
    var surahName: String = ""
    var descriptionText: String = ""
    var reciterName: String = "Alafasy"
    var translationName: String = "English"
    var ayahs: [SurahDetailAyah] = []
    var bookmarkedAyahs: Set<Int> = []
    var isLoading = false
    var errorMessage: String?
    var playingAyahID: Int?
    var scrollToAyah: Int?
    var recitationItems: [ItemSelector] = []
    var translationItems: [ItemSelector] = []
    var selectedRecitationValue: String?
    var selectedTranslationValue: String?

    @ObservationIgnored
    var onTitleChange: ((String) -> Void)?

    @ObservationIgnored
    var onError: ((String) -> Void)?

    @ObservationIgnored
    private let surahService: SurahService

    @ObservationIgnored
    private let bookmarkedAyah: Int?

    @ObservationIgnored
    private let scrollToSpecificAyah: Bool

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var hasLoaded = false

    @ObservationIgnored
    private var hasLoadedEditions = false

    @ObservationIgnored
    private var audioPlayer: AVPlayer?

    @ObservationIgnored
    private var audioEndObserver: NSObjectProtocol?

    init(
        surahService: SurahService,
        bookmarkedAyah: Int? = nil,
        scrollToSpecificAyah: Bool = false
    ) {
        self.surahService = surahService
        self.bookmarkedAyah = bookmarkedAyah
        self.scrollToSpecificAyah = scrollToSpecificAyah
    }

    deinit {
        audioPlayer?.pause()

        if let audioEndObserver {
            NotificationCenter.default.removeObserver(audioEndObserver)
        }
    }

    func loadIfNeeded() {
        loadEditionsIfNeeded()

        guard !hasLoaded, !isLoading else { return }

        load()
    }

    func reload() {
        hasLoaded = false
        load()
    }

    private func load() {
        guard let selectedSurahNo, !isLoading else { return }

        isLoading = true

        let selectedRecitationData: EditionResponse? = Storage.loadObject(
            key: .selectedRecitation
        )
        let recitationId = selectedRecitationData?.identifier ?? "ar.alafasy"

        let selectedTranslationData: EditionResponse? = Storage.loadObject(
            key: .selectedTranslation
        )
        let translationId = selectedTranslationData?.identifier ?? "en.asad"

        surahService.getSurahDetail(
            surahNo: selectedSurahNo,
            recitationId: recitationId,
            translationId: translationId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }

            self.isLoading = false

            if case .failure(let error) = completion {
                self.showError(
                    (error as? RequestError)?.message
                        ?? error.localizedDescription
                )
            }
        } receiveValue: { [weak self] surah in
            self?.handleSurahDetail(surah)
        }
        .store(in: &cancellables)
    }

    private func handleSurahDetail(_ surah: Surah) {
        guard let surahEditions = surah.data,
              let firstEdition = surahEditions.first,
              let surahName = firstEdition.englishName,
              let surahNo = firstEdition.number,
              let origin = firstEdition.revelationType,
              let numberOfAyahs = firstEdition.numberOfAyahs,
              let translationSurahName = firstEdition.englishNameTranslation,
              let surahAyahs = firstEdition.ayahs,
              let translationAyahs = surahEditions.last?.ayahs,
              let translationEdition = surahEditions.last?.edition else {
            return
        }

        let selectedRecitationData: EditionResponse? = Storage.loadObject(
            key: .selectedRecitation
        )
        let selectedTranslationData: EditionResponse? = Storage.loadObject(
            key: .selectedTranslation
        )

        title = surahName
        self.surahName = surahName
        onTitleChange?(surahName)

        reciterName = selectedRecitationData?.englishName ?? "Alafasy"
        selectedRecitationValue = selectedRecitationData?.identifier

        if let selectedTranslationData {
            let language = Constants.getLanguageFromCode(
                code: selectedTranslationData.language ?? ""
            )
            translationName = language
            selectedTranslationValue = selectedTranslationData.identifier
        } else {
            translationName = "English"
            selectedTranslationValue = nil
        }

        descriptionText = String(
            format: NSLocalizedString(
                "surah_description",
                comment: ""
            ),
            surahName,
            translationSurahName,
            String(numberOfAyahs),
            String(surahNo),
            origin.lowercased() == "meccan" ? "Makkah" : "Madinah"
        )

        let translationIsRTL = translationEdition.direction == .rightToLeft
        var loadedAyahs = [SurahDetailAyah]()

        for (index, ayah) in surahAyahs.enumerated() {
            guard let arabicVerse = ayah.text,
                  let numberInSurah = ayah.numberInSurah,
                  index < translationAyahs.count,
                  let translationVerse = translationAyahs[index].text else {
                continue
            }

            let displayArabic: String
            if surahNo != 1 && numberInSurah == 1 {
                displayArabic = (arabicVerse as NSString).replacingOccurrences(
                    of: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ",
                    with: ""
                )
            } else {
                displayArabic = arabicVerse
            }

            loadedAyahs.append(
                SurahDetailAyah(
                    id: numberInSurah,
                    numberInSurah: numberInSurah,
                    arabic: displayArabic,
                    translation: translationVerse,
                    audioURL: ayah.audio.flatMap(URL.init(string:)),
                    translationIsRTL: translationIsRTL
                )
            )
        }

        self.ayahs = loadedAyahs
        bookmarkedAyahs = bookmarkedNumbers(for: surahNo)
        isLoading = false
        hasLoaded = true

        if scrollToSpecificAyah, let bookmarkedAyah {
            guard bookmarkedAyah > 0 else {
                showError(
                    NSLocalizedString(
                        "common_error_content",
                        comment: ""
                    )
                )
                return
            }

            guard self.ayahs.contains(where: {
                $0.numberInSurah == bookmarkedAyah
            }) else {
                showError(
                    String(
                        format: NSLocalizedString(
                            "surah_scroll_to_ayah_out_of_range_error",
                            comment: ""
                        ),
                        String(bookmarkedAyah),
                        String(ayahs.count)
                    )
                )
                return
            }

            scrollToAyah = bookmarkedAyah
        }
    }

    private func loadEditionsIfNeeded() {
        guard !hasLoadedEditions else { return }

        hasLoadedEditions = true

        surahService.getSurahEdition()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }

                if case .failure(let error) = completion {
                    self.showError(
                        (error as? RequestError)?.message
                            ?? error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] edition in
                self?.handleEditions(edition)
            }
            .store(in: &cancellables)
    }

    private func handleEditions(_ edition: Edition) {
        guard let editions = edition.data else { return }

        let selectedRecitationData: EditionResponse? = Storage.loadObject(
            key: .selectedRecitation
        )
        let selectedTranslationData: EditionResponse? = Storage.loadObject(
            key: .selectedTranslation
        )

        selectedRecitationValue = selectedRecitationData?.identifier
        selectedTranslationValue = selectedTranslationData?.identifier

        recitationItems = editions
            .filter {
                $0.format == .audio
                    && $0.language == "ar"
                    && $0.type == "versebyverse"
            }
            .map {
                ItemSelector(
                    title: $0.englishName ?? "",
                    value: $0.identifier ?? "",
                    item: $0
                )
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

    func selectRecitation(_ item: ItemSelector) {
        guard let recitation = item.item as? EditionResponse else { return }

        do {
            try save(recitation, key: .selectedRecitation)
            reciterName = recitation.englishName ?? "Alafasy"
            selectedRecitationValue = recitation.identifier
            reload()
        } catch {
            showError(error.localizedDescription)
        }
    }

    func selectTranslation(_ item: ItemSelector) {
        guard let translation = item.item as? EditionResponse else { return }

        do {
            try save(translation, key: .selectedTranslation)
            translationName = Constants.getLanguageFromCode(
                code: translation.language ?? ""
            )
            selectedTranslationValue = translation.identifier
            reload()
        } catch {
            showError(error.localizedDescription)
        }
    }

    func toggleBookmark(ayah: SurahDetailAyah) {
        guard let selectedSurahNo else { return }

        let bookmark = SurahBookmark(
            surahNumber: selectedSurahNo,
            numberInSurah: ayah.numberInSurah
        )

        let bookmarks = HidayahStore.shared.toggleBookmark(bookmark)
        bookmarkedAyahs = Set(
            bookmarks
                .filter { $0.surahNumber == selectedSurahNo }
                .map(\.numberInSurah)
        )
    }

    func toggleAudio(ayah: SurahDetailAyah) {
        if playingAyahID == ayah.id {
            audioPlayer?.pause()
            playingAyahID = nil
            return
        }

        audioPlayer?.pause()
        playingAyahID = nil

        if let audioEndObserver {
            NotificationCenter.default.removeObserver(audioEndObserver)
            self.audioEndObserver = nil
        }

        guard let audioURL = ayah.audioURL else { return }

        let item = AVPlayerItem(url: audioURL)
        let player = AVPlayer(playerItem: item)
        audioPlayer = player
        playingAyahID = ayah.id

        audioEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.playingAyahID = nil
        }

        player.play()
    }

    func shareText(for ayah: SurahDetailAyah) -> String {
        guard let selectedSurahNo else { return ayah.arabic }

        return "\(ayah.arabic)\n\(ayah.translation) [\(selectedSurahNo):\(ayah.numberInSurah)]\n\nShared from Hidayah App\nhidayahapp://inAppDeeplink/quran/\(selectedSurahNo)/\(ayah.numberInSurah)"
    }

    private func showError(_ message: String) {
        errorMessage = message
        onError?(message)
    }

    private func bookmarkedNumbers(for surahNumber: Int) -> Set<Int> {
        Set(
            HidayahStore.shared.bookmarks()
                .filter { $0.surahNumber == surahNumber }
                .map(\.numberInSurah)
        )
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
