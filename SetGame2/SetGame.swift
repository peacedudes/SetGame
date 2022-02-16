//
//  SetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import Foundation

struct SetGame {
    private(set) var score = 0
    private(set) var cards = (0 ..< 81).map { SetCard(id: $0) } .shuffled()
    private(set) var minimumCardsToShow = 12

    private(set) var selectedCards: [SetCard] = []
    private(set) var isMatchedSet: Bool = false
    var isMisMatchedSet: Bool { selectedCards.count == 3 && !isMatchedSet }

    private var numberOfCardsInPlay: Int {
        cards.reduce(0) { $0 + ($1.state == .inPlay ? 1 : 0) }
    }
    
    var cardsToDeal: Int {
        let neededCards = minimumCardsToShow - numberOfCardsInPlay + (isMatchedSet ? 3 : 0)
        return max(0, neededCards)
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }

    mutating func mix() {
        let cardsInPlay = cards.enumerated().filter { $1.state != .undealt }
        for card in cardsInPlay {
            let swap = cardsInPlay.randomElement()!
            cards.swapAt(card.0, swap.0)
        }
    }

    fileprivate mutating func updateSelection() {
        selectedCards = cards.filter { $0.isSelected }
    }

    fileprivate mutating func updateScore() {
        switch outcome {
        case .none: break
        case .match: score += 12
        case .mismatch: score += -3
        case .matchable: break
        case .unmatchable: score += -1
        }
    }
    
    mutating func choose(_ card: SetCard) {
        let isSelectingANewCard = !selectedCards.contains(card)
        if selectedCards.count < 3 {
            toggleSelected(card)
            updateSelection()
            isMatchedSet = selectedCards.isMatchedSet
            if isSelectingANewCard {
                updateScore()
            }
        } else { // A complete set was already selected
            selectedCards.forEach { toggleSelected($0) }
            discardSetIfMatched()
            if isSelectingANewCard {
                toggleSelected(card)
            }
            updateSelection()
            updateScore()
        }
    }
    
    enum Outcome: String {
        case match, mismatch, matchable, unmatchable, none
    }
    
    var outcome: Outcome {
        selectedCards.count == 0 ? .none :
        isMatchedSet ? .match :
        isMisMatchedSet ? .mismatch :
        hasPlayableMatch(selectedCards) ? .matchable :
            .unmatchable
    }
    
    func playableMatches(_ chosen: [SetCard]) -> [SetCard] {
        switch chosen.count {
        case 0:
            return cards.filter { $0.state == .inPlay && hasPlayableMatch([$0]) }
        case 1:
            return cards.filter { $0.state == .inPlay && $0.id != chosen[0].id && hasPlayableMatch([chosen[0], $0]) }
        case 2:
            let neededId = chosen[0].match(for: chosen[1])
            return cards.filter { $0.state == .inPlay && $0.id == neededId }
        default:
            return []
        }
    }
    
    
    func hasPlayableMatch(_ chosen: [SetCard]) -> Bool {
        switch chosen.count {
        case 0:
            let inPlay = cards.filter { $0.state == .inPlay }
            return inPlay.first(where: { hasPlayableMatch([$0]) }) != nil
        case 1:
            let peers = cards.filter { $0.state == .inPlay && $0.id != chosen[0].id }
            return peers.first(where: { hasPlayableMatch([chosen[0], $0]) }) != nil
        case 2:
            let neededId = chosen[0].match(for: chosen[1])
            let match = cards.first { $0.id == neededId }
            return match?.state == .inPlay
        default:
            return false
        }
    }

    // TODO: change to a deal-one-card model
    mutating func deal() {
        var count = 1
        if isMisMatchedSet {
            choose(selectedCards[0])
        }

        if isMatchedSet {
            minimumCardsToShow = numberOfCardsInPlay
            discardSetIfMatched()
            minimumCardsToShow = 12
            count -= 3
            guard count >= 0 else { return }
        }
//        count = max(count, minimumCardsToShow - numberOfCardsInPlay)
        for _ in 0..<count { dealOneCard() }
    }

    var nextUndealtCard: Int? {
        cards.firstIndex { $0.state == .undealt }
    }

    @discardableResult
    mutating func dealOneCard() -> Int? {
        guard let index = nextUndealtCard else { return nil }
        cards[index].state = .inPlay
        cards[index].isFaceUp = true
        return index
    }

    func cardIndex(of card: SetCard) -> Int? { cards.firstIndex { $0.id == card.id } }
    
    mutating func toggleFaceUp(_ card: SetCard) {
        guard let index = cardIndex(of: card) else { return }
        cards[index].isFaceUp.toggle()
    }
    
    private mutating func toggleSelected(_ card: SetCard) {
        guard let index = cardIndex(of: card) else { return }
        cards[index].isSelected.toggle()
    }

    private mutating func discardSetIfMatched() {
        if isMatchedSet {
            selectedCards.forEach { discard($0) }
            isMatchedSet = false
            updateSelection()
        }
    }

    private mutating func discard(_ card: SetCard) {
        guard let index = cardIndex(of: card) else { return }
        cards[index].state = .discarded
        cards[index].isSelected = false

        // Swap matched set with newly dealt cards so no other cards move
        if numberOfCardsInPlay < minimumCardsToShow,
           let newCardIndex = dealOneCard() {
            cards.swapAt(index, newCardIndex)
        }
    }
}
