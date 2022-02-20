//
//  StdSetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import AVFoundation
import SwiftUI

/// UserDefaults persistant data name
enum Literal {
    static let hintLevel = "hintLevel"
    static let highScore = "highScore"
}

class StdSetGame: ObservableObject {
    
    @Published private var model = SetGame()
    var cards: [SetCard] { model.cards }
    var score: Int { model.score }
    var isMatchedSet: Bool { model.isMatchedSet }
    var isMisMatchedSet: Bool { model.isMisMatchedSet }
    
    let minimumCardsToShow = 12
    var cardsToDeal: Int {
        let neededCards = minimumCardsToShow - model.numberOfCardsInPlay + (isMatchedSet ? 3 : 0)
        return max(0, neededCards)
    }

    @Published private(set) var hintLevel = UserDefaults.standard.integer(forKey: Literal.hintLevel)
    @Published private(set) var highScore = max(100, UserDefaults.standard.integer(forKey: Literal.highScore))

    var isHelpEnabled: Bool { hintLevel > 0 }
    var isHushed: Bool { hintLevel < 2 }
    @Published private(set) var hint: String?
    
    fileprivate func provideHint(_ message: String? = nil) {
        
        hint = isHelpEnabled ? (message ?? model.feedback ?? "_") : message
        
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
        if model.score > highScore {
            highScore = model.score
            UserDefaults.standard.set(highScore, forKey: Literal.highScore)
        }
        provideHint()
    }
    
    
    /// [card.id: delay]
    @Published var dealAnimation: [Int: Double] = [:]
    
    /**
     Prepare  to deal the next few cards by setting a launch order timing delay for each.

     Cards are dealt from the deck, but turn faceUp in onAppear in playingField... the timings must match.
     dealAnimation is a scratch pad [card.id: animation delay] for synchronizing these animations.
     */
    private func setDealAnimation(for cards: [SetCard], delayed: Double = 0) {
        let perCardDelay = min(clock, Style.totalDealDuration * pacing / Double(cards.count))
        var startTime = delayed
        for card in cards {
            dealAnimation[card.id] = startTime
            startTime += Double.random(in: 0...(perCardDelay * 1.5))
        }
    }

    func deal(_ wanted: Int = 0) {
        let neededCards = max(cardsToDeal, wanted)
        guard neededCards > 0 || isMatchedSet else { return }
        var existingMatch = isMatchedSet ? model.selectedCards : []
        let formerOutcome = model.outcome
    
        // TODO: how to avoid any delay if cards don't need to be resized?
        // The delay is to give field time to resize layout for new cards
        let delay = !isMatchedSet ? clock / 8 : 0
        let cardsToDeal = Array(cards.filter { $0.isUndealt }.prefix(neededCards))
        setDealAnimation(for: cardsToDeal, delayed: delay)
        for card in cardsToDeal {
            // TODO: I don't think Style.cardDealDuration is right here...and there
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
        setDealAnimation(for: existingMatch)
        for card in existingMatch {
            withAnimation(.easeInOut(duration: Style.cardDealDuration)
                            .delay(dealAnimation[card.id, default: 0] / 5)
            ) {
                // TODO: delay here??  .. didn't look right
                model.discard(card)
            }
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
    private func lowestTerms(_ lhs: Int, _ rhs: Int) -> (Int, Int) {
        func gcd(_ a: Int, _ b: Int) -> Int {
            if b == 0 { return a }
            return gcd(b, a % b)
        }
        let gcd = gcd(lhs, rhs)
        return (numerator: lhs / gcd, denominator: rhs / gcd)
    }

    func suggestions() -> [Int] {
        var choices: [Int] = []
        choices = model.playableMatches(model.selectedCards) .map { $0.id }
        
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
//            choices = model.playableMatches(model.selectedCards) .map { $0.id }
            let cardsInPlay = model.numberOfCardsInPlay
            var hint = "\(choices.count) choices"
            if choices.count > 0 {
                let unchosenCards = cardsInPlay - model.selectedCards.count
                let odds = lowestTerms(choices.count, unchosenCards)
                let percentGood = odds.0 * 100 / odds.1
                    hint +=
                    percentGood == 100 ? ", choose any card" :
                    percentGood >= 80 ? ", most can match" :
                    unchosenCards == odds.1 ? ", or \(percentGood)% guessable" :
                    ", or \(odds.0) in \(odds.1) can match"
            } else {
                let undealt = cards.filter { $0.isUndealt } .count
                hint = (model.selectedCards.count > 0 ? "try choosing a different card" :
                            undealt < 1 ? "start a New Game" :
                            cardsInPlay < 3 ? "tap the deck to begin" :
                            "deal more cards")
            }
            provideHint(hint)
        }
        return choices
    }
    
    func toggleFaceUp(_ card: SetCard) {
        model.toggleFaceUp(card)
    }
    
    func toggleHint() {
        hintLevel = (hintLevel + 1) % 3
        UserDefaults.standard.set(hintLevel, forKey: Literal.hintLevel)
        provideHint()
    }
    
    @Published private(set) var pace = 0
    private var pacing: Double { pace == 0 ? 1 : 5 }
    var clock: Double { Style.tick * pacing }
    func toggleSpeed() {
        pace = (pace + 1) % 2
    }
}
