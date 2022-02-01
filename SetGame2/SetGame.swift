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
    
    mutating func shuffle() {
        cards.shuffle()
    }

    mutating func choose(_ card: SetCard) {
        if selectedCards.count < 3 {
            let isTurningFaceUp = !selectedCards.contains(card)
            toggleSelected(card)
            selectedCards = cards.filter { $0.isSelected }
            isMatchedSet = selectedCards.isMatchedSet
            if isTurningFaceUp {
                switch outcome {
                case .none: break
                case .match: score += 12
                case .mismatch: score += -3
                case .matchable: break
                case .unmatchable: score += -1
                }
            }

        } else { // A complete set was already selected
            selectedCards.forEach { toggleSelected($0) }
            discardSetIfMatched()
            if !selectedCards.contains(card) {
                toggleSelected(card)
            }
            selectedCards = cards.filter { $0.isSelected }
            if outcome == .unmatchable {
                score += -1
            }
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
    

    mutating func deal(_ count: Int) {
        var count = count
        if isMatchedSet {
            minimumCardsToShow = numberOfCardsInPlay
            discardSetIfMatched()
            minimumCardsToShow = 12
            count -= 3
            guard count >= 0 else { return }
        }
        for _ in 0..<count { dealOneCard() }
    }

    var nextUndealtCard: Int? {
        cards.firstIndex { $0.state == .undealt }
    }

    @discardableResult
    mutating func dealOneCard() -> Int? {
        guard let index = nextUndealtCard else { return nil }
        cards[index].state = .inPlay
        return index
    }

    private mutating func toggleSelected(_ card: SetCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].isSelected.toggle()
    }

    private mutating func discardSetIfMatched() {
        if isMatchedSet {
            selectedCards.forEach { discard($0) }
            isMatchedSet = false
        }
    }

    private mutating func discard(_ card: SetCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].state = .discarded

        // Swap matched set with newly dealt cards so no other cards move
        if numberOfCardsInPlay < minimumCardsToShow,
           let newCardIndex = dealOneCard() {
            cards.swapAt(index, newCardIndex)
        }
    }
}
/**
 SetCards have four traits, each of three possible values.
 It's helpful to think of each trait as being a place holder for a base 3 value
 There are 81 unique cards, or 3 * 3 * 3 * 3
 By assigning id to 0...80, we can directly derive the traits from the id.
 */
struct SetCard: Identifiable, Equatable {
    /// 0...80 (or 0000...2222 in base 3).
    let id: Int
    var isSelected = false
    var state = State.undealt

    enum State {
        case undealt, inPlay, discarded
    }

    init(id rawId: Int) {
        // Todo: is it better to Fail if id >= 81 or negative?
        id = abs(rawId) % 81
    }
}

extension SetCard: CustomStringConvertible {
    var t0: Int { id % 3 }
    var t1: Int { (id / 3) % 3 }
    var t2: Int { (id / 9) % 3 }
    var t3: Int { (id / 27) % 3 }
    
    var description: String {
        "\(t3)\(t2)\(t1)\(t0)"
    }
}

extension Array where Element == SetCard {
    // For each trait, good means all match, or none match
    // Turns out this is true when the sum of each trait (0, 1, 2) equals (0 or 3 or 6).
    var isMatchedSet: Bool {
        count == 3 &&
        self[0].id != self[1].id &&
        map { $0.t0 } .reduce(0, +) % 3 == 0 &&
        map { $0.t1 } .reduce(0, +) % 3 == 0 &&
        map { $0.t2 } .reduce(0, +) % 3 == 0 &&
        map { $0.t3 } .reduce(0, +) % 3 == 0
    }
}

extension SetCard {
    /// Calculate the id of the card that will match two others
    func match(for other: SetCard) -> Int {
        ((6 - (t0 + other.t0)) % 3) * 1 +
        ((6 - (t1 + other.t1)) % 3) * 3 +
        ((6 - (t2 + other.t2)) % 3) * 9 +
        ((6 - (t3 + other.t3)) % 3) * 27
    }
}
