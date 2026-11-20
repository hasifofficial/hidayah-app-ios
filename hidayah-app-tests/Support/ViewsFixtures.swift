//
//  ViewsFixtures.swift
//  simple-quranTests
//
//  JSON fixtures in api.alquran.cloud shapes and a path-based stub router
//  for view tests.
//

import Foundation
import XCTest
@testable import simple_quran

enum ViewsFixtures {
    struct SurahRow {
        let number: Int
        let englishName: String
        let arabic: String
        let ayahs: Int
        let revelation: String
    }

    static let surahs: [SurahRow] = [
        SurahRow(number: 1, englishName: "Al-Faatiha", arabic: "سُورَةُ ٱلْفَاتِحَةِ", ayahs: 7, revelation: "Meccan"),
        SurahRow(number: 2, englishName: "Al-Baqara", arabic: "سورة البقرة", ayahs: 286, revelation: "Medinan"),
        SurahRow(number: 18, englishName: "Al-Kahf", arabic: "سورة الكهف", ayahs: 110, revelation: "Meccan"),
        SurahRow(number: 32, englishName: "As-Sajda", arabic: "سورة السجدة", ayahs: 30, revelation: "Meccan"),
        SurahRow(number: 36, englishName: "Yaseen", arabic: "سورة يس", ayahs: 83, revelation: "Meccan"),
        SurahRow(number: 56, englishName: "Al-Waaqia", arabic: "سورة الواقعة", ayahs: 96, revelation: "Meccan"),
        SurahRow(number: 67, englishName: "Al-Mulk", arabic: "سورة الملك", ayahs: 30, revelation: "Meccan")
    ]

    static var surahListJSON: String {
        surahListJSON(surahs)
    }

    static func surahListJSON(_ rows: [SurahRow]) -> String {
        let items = rows.map { row in
            """
            {"number":\(row.number),"name":"\(row.arabic)","englishName":"\(row.englishName)","englishNameTranslation":"T\(row.number)","numberOfAyahs":\(row.ayahs),"revelationType":"\(row.revelation)"}
            """
        }
        return #"{"code":200,"status":"OK","data":["# + items.joined(separator: ",") + "]}"
    }

    static let editionsJSON = """
    {"code":200,"status":"OK","data":[
    {"identifier":"ar.alafasy","language":"ar","name":"Alafasy","englishName":"Alafasy","format":"audio","type":"versebyverse","direction":null},
    {"identifier":"ar.husary","language":"ar","name":"Husary","englishName":"Husary","format":"audio","type":"versebyverse","direction":null},
    {"identifier":"en.asad","language":"en","name":"Asad","englishName":"Muhammad Asad","format":"text","type":"translation","direction":"ltr"},
    {"identifier":"ur.jalandhry","language":"ur","name":"Jalandhry","englishName":"Jalandhry","format":"text","type":"translation","direction":"rtl"},
    {"identifier":"quran-simple","language":"ar","name":"Simple","englishName":"Simple","format":"text","type":"quran","direction":"rtl"}
    ]}
    """

    /// Two editions (recitation then translation) for surah `number` with
    /// `ayahCount` verses.
    static func surahDetailJSON(
        number: Int = 18,
        englishName: String = "Al-Kahf",
        ayahCount: Int = 3,
        translationDirection: String = "ltr"
    ) -> String {
        let arabic = (1...ayahCount).map { index in
            """
            {"number":\(1000 + index),"audio":"https://example.invalid/\(index).mp3","text":"Arabic \(index)","numberInSurah":\(index),"juz":1,"manzil":1,"page":1,"ruku":1,"hizbQuarter":1}
            """
        }.joined(separator: ",")
        let translation = (1...ayahCount).map { index in
            """
            {"number":\(1000 + index),"audio":null,"text":"Translation \(index)","numberInSurah":\(index),"juz":1,"manzil":1,"page":1,"ruku":1,"hizbQuarter":1}
            """
        }.joined(separator: ",")
        let surah = """
        "number":\(number),"name":"سورة","englishName":"\(englishName)","englishNameTranslation":"The Cave","revelationType":"Meccan","numberOfAyahs":\(ayahCount)
        """
        return """
        {"code":200,"status":"OK","data":[
        {\(surah),"ayahs":[\(arabic)],"edition":{"identifier":"ar.alafasy","language":"ar","name":"Alafasy","englishName":"Alafasy","format":"audio","type":"versebyverse","direction":null}},
        {\(surah),"ayahs":[\(translation)],"edition":{"identifier":"en.asad","language":"en","name":"Asad","englishName":"Muhammad Asad","format":"text","type":"translation","direction":"\(translationDirection)"}}
        ]}
        """
    }

    /// Routes stubbed requests by path. A nil body answers with HTTP 500.
    static func route(
        list: String? = surahListJSON,
        editions: String? = editionsJSON,
        detail: String? = surahDetailJSON()
    ) {
        StubURLProtocol.handler = { request in
            let path = request.url?.path ?? ""
            let body: String?
            if path == "/v1/surah" {
                body = list
            } else if path == "/v1/edition" {
                body = editions
            } else if path.hasPrefix("/v1/surah/") {
                body = detail
            } else {
                body = nil
            }
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: body == nil ? 500 : 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data((body ?? "{}").utf8))
        }
    }

    static let serverErrorMessage = NSLocalizedString(
        "request_error_unexpected_status_code",
        comment: ""
    )

    @MainActor
    static func emptyCatalog() -> SurahCatalog {
        SurahCatalog(cacheURL: nil)
    }

    @MainActor
    static func loadedCatalog() -> SurahCatalog {
        let catalog = SurahCatalog(cacheURL: nil)
        let data = Data(surahListJSON.utf8)
        let list = try! JSONDecoder().decode(SurahList.self, from: data)
        catalog.store(list.data ?? [])
        return catalog
    }

    @MainActor
    static func makeTaskManager(
        store: HidayahStore = makeInMemoryStore()
    ) -> TaskManager {
        TaskManager(
            store: store,
            scheduler: TrackerNotificationScheduler(center: FakeNotificationCenter()),
            now: { TestClock.date(year: 2026, month: 11, day: 3) }
        )
    }
}
