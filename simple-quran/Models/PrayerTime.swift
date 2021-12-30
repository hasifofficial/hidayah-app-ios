//
//  PrayerTime.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Foundation

struct PrayerTime: Codable {
    let code: Int?
    let status: String?
    let data: PrayerTimeResponse?
}

struct PrayerTimeForMonth: Codable {
    let code: Int?
    let status: String?
    let data: [PrayerTimeResponse]?
}

struct PrayerTimeResponse: Codable {
    let timings: PrayerTiming?
    let date: CalenderInfo?
}

struct PrayerTiming: Codable {
    let Fajr: String?
    let Sunrise: String?
    let Dhuhr: String?
    let Asr: String?
    let Sunset: String?
    let Maghrib: String?
    let Isha: String?
    let Imsak: String?
    let Midnight: String?
}

struct CalenderInfo: Codable {
    let readable: String?
    let timestamp: String?
    let hijri: DateResponse?
    let gregorian: DateResponse?
}

struct DateResponse: Codable {
    let date: String?
    let format: String?
    let day: String?
    let weekday: DateInfo?
    let month: DateInfo?
    let year: String?
}

struct DateInfo: Codable {
    let number: Int?
    let en: String?
    let ar: String?
}
