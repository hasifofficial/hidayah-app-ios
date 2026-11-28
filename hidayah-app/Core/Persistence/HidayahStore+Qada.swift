//
//  HidayahStore+Qada.swift
//  hidayah-app
//
//  Qada fasting persistence. The models live in HidayahStore.swift with the
//  schema; this file is app-only, as the widget never reads the ledger.
//

import Foundation
import SwiftData

extension HidayahStore {
    func loadQadaLedger() -> QadaLedger {
        let years = fetch(FetchDescriptor<StoredQadaYear>())
        let fasts = fetch(FetchDescriptor<StoredQadaFast>())

        return QadaLedger(
            owedDays: Dictionary(
                years.map { ($0.hijriYear, $0.owedDays) },
                uniquingKeysWith: { first, _ in first }
            ),
            fasts: fasts.map {
                QadaFast(id: $0.id, date: $0.date, hijriYear: $0.hijriYear)
            }
        )
    }

    func saveQadaYear(hijriYear: Int, owedDays: Int) {
        if let existing = qadaYear(hijriYear) {
            existing.owedDays = owedDays
        } else {
            context.insert(StoredQadaYear(hijriYear: hijriYear, owedDays: owedDays))
        }
        save()
    }

    /// Removes a Ramadan and every fast counted against it.
    func deleteQadaYear(_ hijriYear: Int) {
        if let stored = qadaYear(hijriYear) {
            context.delete(stored)
        }
        let fasts = fetch(
            FetchDescriptor<StoredQadaFast>(
                predicate: #Predicate { $0.hijriYear == hijriYear }
            )
        )
        for fast in fasts {
            context.delete(fast)
        }
        save()
    }

    func insertQadaFast(_ fast: QadaFast) {
        context.insert(
            StoredQadaFast(id: fast.id, date: fast.date, hijriYear: fast.hijriYear)
        )
        save()
    }

    func deleteQadaFast(id: UUID) {
        var descriptor = FetchDescriptor<StoredQadaFast>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        if let stored = fetch(descriptor).first {
            context.delete(stored)
            save()
        }
    }

    private func qadaYear(_ hijriYear: Int) -> StoredQadaYear? {
        var descriptor = FetchDescriptor<StoredQadaYear>(
            predicate: #Predicate { $0.hijriYear == hijriYear }
        )
        descriptor.fetchLimit = 1
        return fetch(descriptor).first
    }
}
