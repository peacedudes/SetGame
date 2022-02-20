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

    private(set) var selectedCards: [SetCard] = []
    private(set) var isMatchedSet: Bool = false
    var isMisMatchedSet: Bool { selectedCards.count == 3 && !isMatchedSet }

    var numberOfCardsInPlay: Int {
        cards.reduce(0) { $0 + ($1.isInPlay ? 1 : 0) }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }

    mutating func mix() {
        let cardsInPlay = cards.enumerated().filter { !$1.isUndealt }
        for card in cardsInPlay {
            let swap = cardsInPlay.randomElement() ?? card
            cards.swapAt(card.0, swap.0)
        }
    }

    fileprivate mutating func updateSelection() {
        selectedCards = cards.filter { $0.isSelected }
        isMatchedSet = selectedCards.isMatchedSet
    }

    fileprivate mutating func updateScore() {
        switch outcome {
        case .none: break
        case .match: score += 12
        case .mismatch: score = max(0, score - 3)
        case .matchable: break
        case .unmatchable: score = max(0, score - 1)
        }
    }
    
    mutating func choose(_ card: SetCard) {
        if selectedCards.count < 3 {
            let card = cards[cardIndex(of: card)]
            if card.isInPlay {
                toggleSelected(card)
                if !card.isSelected {
                    updateScore()
                }
            }

        } else { // A complete set was already selected
            if !selectedCards.contains(card) {
                toggleSelected(card)
            }
            selectedCards.forEach { toggleSelected($0) }
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
            return cards.filter { $0.isInPlay && hasPlayableMatch([$0]) }
        case 1:
            return cards.filter { $0.isInPlay && $0.id != chosen[0].id && hasPlayableMatch([chosen[0], $0]) }
        case 2:
            let neededId = chosen[0].match(for: chosen[1])
            return cards.filter { $0.isInPlay && $0.id == neededId }
        default:
            return []
        }
    }
    
    
    func hasPlayableMatch(_ chosen: [SetCard]) -> Bool {
        switch chosen.count {
        case 0:
            let inPlay = cards.filter { $0.isInPlay }
            return inPlay.first(where: { hasPlayableMatch([$0]) }) != nil
        case 1:
            let peers = cards.filter { $0.isInPlay && $0.id != chosen[0].id }
            return peers.first(where: { hasPlayableMatch([chosen[0], $0]) }) != nil
        case 2:
            let neededId = chosen[0].match(for: chosen[1])
            let match = cards.first { $0.id == neededId }
            return match?.isInPlay ?? false
        default:
            return false
        }
    }

    var nextUndealtCard: Int? { cards.firstIndex { $0.isUndealt } }
    var isDeckEmpty: Bool { nextUndealtCard == nil }

    @discardableResult
    mutating func dealOneCard() -> SetCard? {
        guard let topCard = nextUndealtCard else { return nil }
        cards[topCard].state = .inPlay
        cards[topCard].isFaceUp = true
        return cards[topCard]
    }

    func cardIndex(of card: SetCard) -> Int { cards.firstIndex { $0.id == card.id } ?? 0 }
    
    mutating func toggleFaceUp(_ card: SetCard) {
        cards[cardIndex(of: card)].isFaceUp.toggle()
    }
    
    private mutating func toggleSelected(_ card: SetCard) {
        cards[cardIndex(of: card)].isSelected.toggle()
        updateSelection()
    }

    mutating func discard(_ card: SetCard) {
        let index = cardIndex(of: card)
        cards[index].state = .discarded
        cards[index].isSelected = false
        updateSelection()
    }
    
    mutating func swap(_ card1: SetCard, _ card2: SetCard) {
        cards.swapAt(cardIndex(of: card1), cardIndex(of: card2))
    }
}
