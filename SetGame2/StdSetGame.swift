//
//  StdSetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import AVFoundation
import SwiftUI

class StdSetGame: ObservableObject {
    
    @Published private var model = SetGame()
    var cards: [SetCard] { model.cards }
    var score: Int { model.score }
    var isMatchedSet: Bool { model.isMatchedSet }
    var isMisMatchedSet: Bool { model.isMisMatchedSet }
    var cardsToDeal: Int { model.cardsToDeal }
//    var selectedCards: [SetCard] { model.selectedCards }

    @Published private(set) var isHushed = true
    @Published private(set) var hint: String?
    
    fileprivate func provideHint(_ message: String? = nil) {
         hint = message ?? model.feedback ?? "_"
         if !isHushed, let spokenText = hint, spokenText.count > 1 {
             if model.hasPlayableMatch(model.selectedCards) {
                 spokenText.speak(voice: Voice.named(Style.whisper))//, rate: 0.8)
             } else {
                 spokenText.speak()
             }
         }
     }

    private var explainMismatch: String {
        var problems = mismatchErrors(model.selectedCards)
        if problems.count > 1 {
            problems[problems.count - 1] = "or " + problems[problems.count - 1]
        }
        return problems.joined(separator: ", ")
    }
    
    private func mismatchErrors(_ cards: [SetCard]) -> [String] {
        var problems = [String]()
        guard !cards.isMatchedSet else { return [] }
        guard cards.count == 3 else { return ["\(cards.count) cards"] }
        let (first, second) = (cards[0], cards[1])

        // If there's a mismatch, two traits match
        // if the 1st and 2nd don't match, then the 3rd card must match one of them

        if !cards.isT0Matched { // fill
            problems.append(cards[first.t0 == second.t0 ? 0 : 2].t0Name)
        }
        if !cards.isT1Matched { // color
            problems.append(cards[first.t1 == second.t1 ? 0 : 2].t1Name)
        }
        if !cards.isT2Matched { // shape
            problems.append(cards[first.t2 == second.t2 ? 0 : 2].t2Name)
        }
        if !cards.isT3Matched { // number
            problems.append(cards[first.t3 == second.t3 ? 0 : 2].t3Name)
        }
        return problems.map { "two \($0)s" }
    }

    // MARK: - Intents

    func choose(_ card: SetCard) {
        model.choose(card)
        if !card.isSelected || model.selectedCards.count == 0 {
            provideHint()
        } else {
            hint = nil
        }
    }
    
    func deal() {
        let formerOutcome = model.outcome
        model.deal()
        provideHint()
        let newOutcome = model.outcome
        if newOutcome != formerOutcome || newOutcome == .none {
            provideHint()
        }
    }
    
    func newGame() {
        model = SetGame()
        hint = nil
//        deal(model.minimumCardsToShow)
    }

    // Not a true shuffle; only mixes faceUp cards
    func shuffle() {
        model.mix()
    }
    
    func suggestions() -> [Int] {
        var choices: [Int] = []
        switch model.selectedCards.count {
        case 3:
            provideHint(isMisMatchedSet ? explainMismatch : "Keep it up")

        case 2:
            let neededId = model.selectedCards[0].match(for: model.selectedCards[1])
            let card = cards.first { $0.id == neededId }
            provideHint("You need " + SetCard(id: neededId).cardName)
            if card?.state == .inPlay {
                choices.append(neededId)
            }
        default:
            choices = model.playableMatches(model.selectedCards) .map { $0.id }
            provideHint(choices.count == 0 ? "no matches" : "\(choices.count) choices")
        }
        return choices
    }
    
    func toggleFaceUp(_ card: SetCard) {
        model.toggleFaceUp(card)
    }
    
    func toggleSound() {
        isHushed.toggle()
        if !isHushed {
            provideHint()
        }
    }
}
