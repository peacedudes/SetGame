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

    @Published private(set) var hintLevel = 0
    var isHelpEnabled: Bool { hintLevel > 0 }
    var isHushed: Bool { hintLevel < 2 }
    @Published private(set) var hint: String?
    
    fileprivate func provideHint(_ message: String? = nil) {
        hint = !isHelpEnabled ? message : message ?? model.feedback ?? "_"
        
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
        return problems.map { "two are \($0)" }
    }

    // MARK: - Intents

    func choose(_ card: SetCard) {
        if isMatchedSet {
            deal(0) // replace any matched set
        }
        model.choose(card)
        provideHint()
    }
    
    
    @Published var dealAnimation: [Int: Double] = [:]
    /**
     Prepare  to deal the next cardCount cards, setting a launch order timing delay for each.  The cards are not dealt.
     - Parameter cardCount: The number of cards that will be dealt
     - Returns: the actual cards to be dealt

     Cards are dealt from the deck, but turn faceUp in onAppear in playingField, and the timings must match.
     dealAnimation is a scratch pad [card.id: animation delay] for synchronizing these animations.
     */
    @discardableResult
    private func setDealAnimation(for cardCount: Int, delayed: Double = 0) -> [SetCard] {
        let cardsToDeal = Array(cards.filter { $0.isUndealt }.prefix(cardCount))
        let perCardDelay = min(Style.tick, Style.totalDealDuration / Double(cardCount))
        var startTime = delayed
        for card in cardsToDeal {
            dealAnimation[card.id] = startTime
            startTime += Double.random(in: 0...(perCardDelay * 1.5))
        }
        return cardsToDeal
    }

    func deal(_ wanted: Int = 0) {
        let neededCards = max(cardsToDeal, wanted)
        var existingMatch = isMatchedSet ? model.selectedCards : []
        guard neededCards > 0 || isMatchedSet else { return }
        let formerOutcome = model.outcome
    
        let delay = !isMatchedSet ? Style.tick / 2 : 0
        let cardsToDeal = setDealAnimation(for: neededCards, delayed: delay)
        for card in cardsToDeal {
            withAnimation(.easeInOut(duration: Style.cardDealDuration)
                            .delay(dealAnimation[card.id] ?? 0)) {
                if let newCard = model.dealOneCard(), existingMatch.count > 0 {
                    let oldCard = existingMatch.removeFirst()
                    dealAnimation[oldCard.id] = dealAnimation[newCard.id]
                    model.swap(newCard, oldCard)
                    model.discard(oldCard)
                }
            }
        }
        for card in existingMatch {
            model.discard(card)
        }

        let newOutcome = model.outcome
        if newOutcome != formerOutcome || newOutcome == .none {
            provideHint()
        }
    }
    
    func newGame() {
        dealAnimation = [:]
        model = SetGame()
        hint = nil
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
            if let card = cards.first(where: { $0.id == neededId }) {
                provideHint("You need " + SetCard(id: neededId).cardName)
                if card.isInPlay {
                    choices.append(neededId)
                }
            }
        default:
            choices = model.playableMatches(model.selectedCards) .map { $0.id }
            provideHint(choices.count == 0 ? "no sets" : "there are \(choices.count) choices")
        }
        return choices
    }
    
    func toggleFaceUp(_ card: SetCard) {
        model.toggleFaceUp(card)
    }
    
    func toggleHint() {
        hintLevel = (hintLevel + 1) % 3
        provideHint()
    }
}
