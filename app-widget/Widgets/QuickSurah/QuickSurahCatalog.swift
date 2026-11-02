//
//  QuickSurahCatalog.swift
//  app-widget
//

import AppIntents
import Foundation

// MARK: - Surah catalog

struct QuickSurahEntity: AppEntity, Hashable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("widget_surah_type")
    )
    static let defaultQuery = QuickQuickSurahEntityQuery()

    let id: String
    let number: Int
    let englishName: String
    let arabicName: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(englishName)",
            subtitle: "\(number)"
        )
    }
}

struct QuickQuickSurahEntityQuery: EntityStringQuery {
    func entities(
        for identifiers: [QuickSurahEntity.ID]
    ) async throws -> [QuickSurahEntity] {
        QuickSurahCatalog.all.filter { identifiers.contains($0.id) }
    }

    func entities(
        matching string: String
    ) async throws -> [QuickSurahEntity] {
        let query = string.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !query.isEmpty else {
            return QuickSurahCatalog.all
        }

        return QuickSurahCatalog.all.filter {
            $0.englishName.localizedCaseInsensitiveContains(query)
                || $0.arabicName.contains(query)
                || String($0.number) == query
        }
    }

    func suggestedEntities() async throws -> [QuickSurahEntity] {
        QuickSurahCatalog.all
    }
}

enum QuickSurahCatalog {
    static let quickAccess: [QuickSurahEntity] = [
        entity(18), entity(32), entity(36), entity(56), entity(67)
    ]

    static let all: [QuickSurahEntity] = [
        entity(1, "Al-Faatiha", "الفاتحة"),
        entity(2, "Al-Baqara", "البقرة"),
        entity(3, "Aal-i-Imraan", "آل عمران"),
        entity(4, "An-Nisaa", "النساء"),
        entity(5, "Al-Maaida", "المائدة"),
        entity(6, "Al-An'aam", "الأنعام"),
        entity(7, "Al-A'raaf", "الأعراف"),
        entity(8, "Al-Anfaal", "الأنفال"),
        entity(9, "At-Tawba", "التوبة"),
        entity(10, "Yunus", "يونس"),
        entity(11, "Hud", "هود"),
        entity(12, "Yusuf", "يوسف"),
        entity(13, "Ar-Ra'd", "الرعد"),
        entity(14, "Ibrahim", "إبراهيم"),
        entity(15, "Al-Hijr", "الحجر"),
        entity(16, "An-Nahl", "النحل"),
        entity(17, "Al-Israa", "الإسراء"),
        entity(18, "Al-Kahf", "الكهف"),
        entity(19, "Maryam", "مريم"),
        entity(20, "Taa-Haa", "طه"),
        entity(21, "Al-Anbiyaa", "الأنبياء"),
        entity(22, "Al-Hajj", "الحج"),
        entity(23, "Al-Mu'minoon", "المؤمنون"),
        entity(24, "An-Noor", "النور"),
        entity(25, "Al-Furqaan", "الفرقان"),
        entity(26, "Ash-Shu'araa", "الشعراء"),
        entity(27, "An-Naml", "النمل"),
        entity(28, "Al-Qasas", "القصص"),
        entity(29, "Al-Ankaboot", "العنكبوت"),
        entity(30, "Ar-Room", "الروم"),
        entity(31, "Luqman", "لقمان"),
        entity(32, "As-Sajda", "السجدة"),
        entity(33, "Al-Ahzaab", "الأحزاب"),
        entity(34, "Saba", "سبأ"),
        entity(35, "Faatir", "فاطر"),
        entity(36, "Yaseen", "يس"),
        entity(37, "As-Saaffaat", "الصافات"),
        entity(38, "Saad", "ص"),
        entity(39, "Az-Zumar", "الزمر"),
        entity(40, "Al-Ghaafir", "غافر"),
        entity(41, "Fussilat", "فصلت"),
        entity(42, "Ash-Shura", "الشورى"),
        entity(43, "Az-Zukhruf", "الزخرف"),
        entity(44, "Ad-Dukhaan", "الدخان"),
        entity(45, "Al-Jaathiya", "الجاثية"),
        entity(46, "Al-Ahqaf", "الأحقاف"),
        entity(47, "Muhammad", "محمد"),
        entity(48, "Al-Fath", "الفتح"),
        entity(49, "Al-Hujuraat", "الحجرات"),
        entity(50, "Qaaf", "ق"),
        entity(51, "Adh-Dhaariyat", "الذاريات"),
        entity(52, "At-Tur", "الطور"),
        entity(53, "An-Najm", "النجم"),
        entity(54, "Al-Qamar", "القمر"),
        entity(55, "Ar-Rahmaan", "الرحمن"),
        entity(56, "Al-Waaqia", "الواقعة"),
        entity(57, "Al-Hadid", "الحديد"),
        entity(58, "Al-Mujaadila", "المجادلة"),
        entity(59, "Al-Hashr", "الحشر"),
        entity(60, "Al-Mumtahana", "الممتحنة"),
        entity(61, "As-Saff", "الصف"),
        entity(62, "Al-Jumu'a", "الجمعة"),
        entity(63, "Al-Munaafiqoon", "المنافقون"),
        entity(64, "At-Taghaabun", "التغابن"),
        entity(65, "At-Talaaq", "الطلاق"),
        entity(66, "At-Tahrim", "التحريم"),
        entity(67, "Al-Mulk", "الملك"),
        entity(68, "Al-Qalam", "القلم"),
        entity(69, "Al-Haaqqa", "الحاقة"),
        entity(70, "Al-Ma'aarij", "المعارج"),
        entity(71, "Nooh", "نوح"),
        entity(72, "Al-Jinn", "الجن"),
        entity(73, "Al-Muzzammil", "المزمل"),
        entity(74, "Al-Muddaththir", "المدثر"),
        entity(75, "Al-Qiyaama", "القيامة"),
        entity(76, "Al-Insaan", "الإنسان"),
        entity(77, "Al-Mursalaat", "المرسلات"),
        entity(78, "An-Naba", "النبأ"),
        entity(79, "An-Naazi'aat", "النازعات"),
        entity(80, "Abasa", "عبس"),
        entity(81, "At-Takwir", "التكوير"),
        entity(82, "Al-Infitaar", "الانفطار"),
        entity(83, "Al-Mutaffifin", "المطففين"),
        entity(84, "Al-Inshiqaaq", "الانشقاق"),
        entity(85, "Al-Burooj", "البروج"),
        entity(86, "At-Taariq", "الطارق"),
        entity(87, "Al-A'laa", "الأعلى"),
        entity(88, "Al-Ghaashiya", "الغاشية"),
        entity(89, "Al-Fajr", "الفجر"),
        entity(90, "Al-Balad", "البلد"),
        entity(91, "Ash-Shams", "الشمس"),
        entity(92, "Al-Lail", "الليل"),
        entity(93, "Ad-Dhuha", "الضحى"),
        entity(94, "Ash-Sharh", "الشرح"),
        entity(95, "At-Tin", "التين"),
        entity(96, "Al-Alaq", "العلق"),
        entity(97, "Al-Qadr", "القدر"),
        entity(98, "Al-Bayyina", "البينة"),
        entity(99, "Az-Zalzala", "الزلزلة"),
        entity(100, "Al-Aadiyaat", "العاديات"),
        entity(101, "Al-Qaari'a", "القارعة"),
        entity(102, "At-Takaathur", "التكاثر"),
        entity(103, "Al-Asr", "العصر"),
        entity(104, "Al-Humaza", "الهمزة"),
        entity(105, "Al-Fil", "الفيل"),
        entity(106, "Quraish", "قريش"),
        entity(107, "Al-Maa'un", "الماعون"),
        entity(108, "Al-Kawthar", "الكوثر"),
        entity(109, "Al-Kaafiroon", "الكافرون"),
        entity(110, "An-Nasr", "النصر"),
        entity(111, "Al-Masad", "المسد"),
        entity(112, "Al-Ikhlaas", "الإخلاص"),
        entity(113, "Al-Falaq", "الفلق"),
        entity(114, "An-Naas", "الناس")
    ]

    private static func entity(
        _ number: Int,
        _ englishName: String,
        _ arabicName: String
    ) -> QuickSurahEntity {
        QuickSurahEntity(
            id: "\(number)",
            number: number,
            englishName: englishName,
            arabicName: arabicName
        )
    }

    private static func entity(_ number: Int) -> QuickSurahEntity {
        guard let surah = all.first(
            where: { $0.number == number }
        ) else {
            return QuickSurahEntity(
                id: "\(number)",
                number: number,
                englishName: "Surah \(number)",
                arabicName: ""
            )
        }
        return surah
    }
}
