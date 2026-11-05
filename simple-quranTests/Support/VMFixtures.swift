//
//  VMFixtures.swift
//  simple-quranTests
//
//  Fixtures and helpers shared by the view model tests.
//

import AVFoundation
import Foundation
@testable import simple_quran

enum VMFixtures {
    // MARK: - Routing

    /// Serves `routes[path]` for each request path; any other path gets a 404.
    static func route(_ routes: [String: (status: Int, json: String)]) {
        StubURLProtocol.handler = { request in
            let path = request.url?.path ?? ""
            let route = routes[path] ?? (status: 404, json: "{}")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: route.status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(route.json.utf8))
        }
    }

    static func requestedPaths() -> [String] {
        StubURLProtocol.requests.compactMap { $0.url?.path }
    }

    // MARK: - Surah list

    static let surahListPath = "/v1/surah"
    static let editionPath = "/v1/edition"

    static func detailPath(
        surahNo: Int,
        recitation: String = "ar.alafasy",
        translation: String = "en.asad"
    ) -> String {
        "/v1/surah/\(surahNo)/editions/\(recitation),\(translation)"
    }

    static func surah(
        _ number: Int,
        _ englishName: String?
    ) -> SurahListResponse {
        SurahListResponse(
            number: number,
            name: "سورة \(number)",
            englishName: englishName,
            englishNameTranslation: "Translation \(number)",
            numberOfAyahs: 7,
            revelationType: "Meccan"
        )
    }

    static let surahs: [SurahListResponse] = [
        surah(1, "Al-Faatiha"),
        surah(2, "Al-Baqara"),
        surah(18, "Al-Kahf"),
        surah(36, "Yaseen")
    ]

    static func surahListJSON(_ surahs: [SurahListResponse] = surahs) -> String {
        let data = try! JSONEncoder().encode(
            SurahList(code: 200, status: "OK", data: surahs)
        )
        return String(decoding: data, as: UTF8.self)
    }

    static let nullDataJSON = #"{"code":200,"status":"OK","data":null}"#

    // MARK: - Editions

    static func edition(
        _ identifier: String,
        language: String,
        name: String,
        englishName: String,
        format: Format,
        type: String,
        direction: TextDirection? = .leftToRight
    ) -> EditionResponse {
        EditionResponse(
            identifier: identifier,
            language: language,
            name: name,
            englishName: englishName,
            format: format,
            type: type,
            direction: direction
        )
    }

    static let alafasy = edition(
        "ar.alafasy",
        language: "ar",
        name: "مشاري العفاسي",
        englishName: "Alafasy",
        format: .audio,
        type: "versebyverse"
    )

    static let husary = edition(
        "ar.husary",
        language: "ar",
        name: "محمود خليل الحصري",
        englishName: "Husary",
        format: .audio,
        type: "versebyverse"
    )

    static let asad = edition(
        "en.asad",
        language: "en",
        name: "Asad",
        englishName: "Muhammad Asad",
        format: .text,
        type: "translation"
    )

    static let indonesian = edition(
        "id.indonesian",
        language: "id",
        name: "Bahasa Indonesia",
        englishName: "Indonesian Ministry of Religious Affairs",
        format: .text,
        type: "translation"
    )

    static let urdu = edition(
        "ur.jalandhry",
        language: "ur",
        name: "جالندہری",
        englishName: "Jalandhry",
        format: .text,
        type: "translation",
        direction: .rightToLeft
    )

    /// Editions the selectors must skip: Arabic text, a non-Arabic audio
    /// edition, and Arabic audio that is not verse by verse.
    static let ignoredEditions: [EditionResponse] = [
        edition(
            "quran-uthmani",
            language: "ar",
            name: "القرآن الكريم",
            englishName: "Uthmani",
            format: .text,
            type: "quran"
        ),
        edition(
            "en.walk",
            language: "en",
            name: "Ibrahim Walk",
            englishName: "Ibrahim Walk",
            format: .audio,
            type: "versebyverse"
        ),
        edition(
            "ar.abdulsamad",
            language: "ar",
            name: "عبد الباسط",
            englishName: "Abdul Samad",
            format: .audio,
            type: "translation"
        )
    ]

    static var allEditions: [EditionResponse] {
        [alafasy, husary, asad, indonesian] + ignoredEditions
    }

    static func editionJSON(_ editions: [EditionResponse] = allEditions) -> String {
        let data = try! JSONEncoder().encode(
            Edition(code: 200, status: "OK", data: editions)
        )
        return String(decoding: data, as: UTF8.self)
    }

    static func saveSelected(_ edition: EditionResponse, key: Storage.StorageKey) {
        Storage.save(key, try! JSONEncoder().encode(edition))
    }

    // MARK: - Surah detail

    static let bismillah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ "

    static func ayah(
        _ numberInSurah: Int,
        text: String?,
        audio: String? = nil
    ) -> Ayah {
        Ayah(
            number: numberInSurah,
            audio: audio,
            text: text,
            numberInSurah: numberInSurah,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1
        )
    }

    static func surahResponse(
        number: Int,
        englishName: String? = "Al-Kahf",
        revelationType: String = "Meccan",
        ayahs: [Ayah],
        edition: EditionResponse
    ) -> SurahResponse {
        SurahResponse(
            number: number,
            name: "الكهف",
            englishName: englishName,
            englishNameTranslation: "The Cave",
            revelationType: revelationType,
            numberOfAyahs: ayahs.count,
            ayahs: ayahs,
            edition: edition
        )
    }

    /// A two-edition detail payload: recitation first, translation last.
    static func detailJSON(
        surahNo: Int = 18,
        englishName: String? = "Al-Kahf",
        revelationType: String = "Meccan",
        arabic: [Ayah]? = nil,
        translation: [Ayah]? = nil,
        translationEdition: EditionResponse = asad
    ) -> String {
        let arabicAyahs = arabic ?? [
            ayah(1, text: bismillah + "ٱلْحَمْدُ لِلَّهِ", audio: "https://cdn.example.com/1.mp3"),
            ayah(2, text: "قَيِّمًا", audio: "https://cdn.example.com/2.mp3"),
            ayah(3, text: "مَّـٰكِثِينَ", audio: nil)
        ]
        let translationAyahs = translation ?? [
            ayah(1, text: "All praise is due to God"),
            ayah(2, text: "Unerringly straight"),
            ayah(3, text: "Therein to dwell")
        ]
        let surah = Surah(
            code: 200,
            status: "OK",
            data: [
                surahResponse(
                    number: surahNo,
                    englishName: englishName,
                    revelationType: revelationType,
                    ayahs: arabicAyahs,
                    edition: alafasy
                ),
                surahResponse(
                    number: surahNo,
                    englishName: englishName,
                    revelationType: revelationType,
                    ayahs: translationAyahs,
                    edition: translationEdition
                )
            ]
        )
        let data = try! JSONEncoder().encode(surah)
        return String(decoding: data, as: UTF8.self)
    }

    // MARK: - Tracker

    @MainActor
    static func makeTaskManager(
        store: HidayahStore = makeInMemoryStore(),
        clock: TestClock = TestClock(TestClock.date(year: 2026, month: 11, day: 3)),
        center: FakeNotificationCenter = FakeNotificationCenter()
    ) -> TaskManager {
        TaskManager(
            store: store,
            scheduler: TrackerNotificationScheduler(center: center),
            now: { clock.now }
        )
    }

    static func snapshot(
        _ name: String,
        category: simple_quran.Category,
        isCompleted: Bool
    ) -> TrackerTaskSnapshot {
        TrackerTaskSnapshot(
            task: TaskDetails(
                name: name,
                category: category,
                isCompleted: isCompleted
            )
        )
    }

    /// A day with `completed` of `total` tasks done.
    static func dayRecord(
        _ dayKey: String,
        completed: Int,
        total: Int
    ) -> TrackerDayRecord {
        let tasks = (0..<total).map { index in
            snapshot(
                "Task \(index)",
                category: .default(.fajr),
                isCompleted: index < completed
            )
        }
        return TrackerDayRecord(dayKey: dayKey, tasks: tasks)
    }
}

// MARK: - Private state access

extension SurahDetailViewModel {
    /// The player the view model created, read via reflection so the
    /// production type needs no test-only API.
    var testAudioPlayer: AVPlayer? {
        Mirror(reflecting: self).children
            .first { $0.label == "audioPlayer" }?
            .value as? AVPlayer
    }
}
