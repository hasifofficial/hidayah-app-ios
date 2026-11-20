//
//  TasbihViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation
import SwiftUI

struct TasbihPhrase {
    let nameKey: String
    let arabic: String
}

@MainActor
@Observable
final class TasbihViewModel {
    let target = 33
    let phrases: [TasbihPhrase] = [
        TasbihPhrase(
            nameKey: "tasbih_phrase_1_title",
            arabic: "سُبْحَانَ ٱللَّٰهِ"
        ),
        TasbihPhrase(
            nameKey: "tasbih_phrase_2_title",
            arabic: "ٱلْحَمْدُ لِلَّٰهِ"
        ),
        TasbihPhrase(
            nameKey: "tasbih_phrase_3_title",
            arabic: "ٱللَّٰهُ أَكْبَرُ"
        )
    ]

    var phraseIndex = 0
    var count = 0
    var freeCount = 0
    var isFreeCount = false
    var isCompleting = false
    var showCompletion = false

    var currentPhrase: TasbihPhrase {
        phrases[phraseIndex]
    }

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(count) / Double(target), 1)
    }

    var displayedCount: Int {
        isFreeCount ? freeCount : count
    }

    var canDecrement: Bool {
        displayedCount > 0 && !isCompleting
    }

    func toggleFreeCount() {
        isFreeCount.toggle()
    }

    func increment() {
        guard !isCompleting else { return }

        AppHaptics.tap()

        if isFreeCount {
            freeCount += 1
            return
        }

        count += 1

        guard count >= target else { return }
        completeRound()
    }

    func decrement() {
        guard canDecrement else { return }
        AppHaptics.tap()

        if isFreeCount {
            freeCount -= 1
        } else {
            count -= 1
        }
    }

    func selectPhrase(_ index: Int) {
        guard !isCompleting, index != phraseIndex else { return }

        AppHaptics.selection()

        withAnimation(.easeInOut(duration: 0.22)) {
            phraseIndex = index
            count = 0
        }
    }

    func resetCurrent() {
        guard !isCompleting else { return }
        AppHaptics.tap()

        withAnimation(.easeInOut(duration: 0.2)) {
            if isFreeCount {
                freeCount = 0
            } else {
                count = 0
            }
        }
    }

    func startAgain() {
        AppHaptics.success()

        withAnimation(.easeInOut(duration: 0.25)) {
            count = 0
            freeCount = 0
            phraseIndex = 0
            isFreeCount = false
            showCompletion = false
            isCompleting = false
        }
    }

    private func completeRound() {
        isCompleting = true
        AppHaptics.success()

        if phraseIndex == phrases.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showCompletion = true
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.count = 0
                self.phraseIndex += 1
                self.isCompleting = false
            }
        }
    }
}
