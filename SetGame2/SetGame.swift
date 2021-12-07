//
//  SetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import Foundation

struct SetGame {
    private(set) var score = 0
    private(set) var cards = (0..<18).map { SetCard(id: $0) } .shuffled()
    private(set) var minimumCardsToShow = 12

    private(set) var selectedCards: [SetCard] = []
    private(set) var isMatchedSet: Bool = false

    private var numberOfCardsInPlay: Int { cards.filter({ $0.state == .inPlay }).count }
    
    mutating func shuffle() {
        cards.shuffle()
    }

    mutating func choose(_ card: SetCard) {
        if selectedCards.count < 3 {
            toggleSelected(card)
            selectedCards = cards .filter { $0.isSelected }
            isMatchedSet = selectedCards.count == 3 && SetCard.isMatch(selectedCards)

        } else { // A complete set was already selected
            selectedCards.forEach { toggleSelected($0) }
            discardSetIfMatched()
            if !selectedCards.contains(card) {
                toggleSelected(card)
            }
            selectedCards = cards.filter { $0.isSelected }
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

    @discardableResult
    mutating func dealOneCard() -> Int? {
        guard let index = cards.firstIndex(where: { $0.state == .undealt }) else { return nil }
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
//        guard let index = cards.firstIndex(of: card) else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].state = .discarded

        // A little hacky, maybe.  We replace matched cards with newly dealt ones so no other cards move aroune.
        if numberOfCardsInPlay < minimumCardsToShow,
           let newCardIndex = dealOneCard() {
            cards.swapAt(index, newCardIndex)
        }
    }
}

struct SetCard: Identifiable, Equatable {
    // 0-81  (0000 - 2222)
    let id: Int
    var isSelected = false
    var state = State.undealt

    enum State {
        case undealt, inPlay, discarded
    }

    init(id rawId: Int) {
        // Todo: is it better to Fail id >= 81 or negative?
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

extension SetCard {
    
    static func isMatch(_ set: [SetCard]) -> Bool {
        set.count == 3 &&
        set[0].id != set[1].id &&
        set.map { $0.t0 } .reduce(0, +) % 3 == 0 &&
        set.map { $0.t1 } .reduce(0, +) % 3 == 0 &&
        set.map { $0.t2 } .reduce(0, +) % 3 == 0 &&
        set.map { $0.t3 } .reduce(0, +) % 3 == 0
    }
    
    // For each trait, good means all match, or none match
    static func isMatch(_ card1: SetCard, _ card2: SetCard, _ card3: SetCard) -> Bool {
        (card1.t0 + card2.t0 + card3.t0) % 3 == 0 &&
        (card1.t1 + card2.t1 + card3.t1) % 3 == 0 &&
        (card1.t2 + card2.t2 + card3.t2) % 3 == 0 &&
        (card1.t3 + card2.t3 + card3.t3) % 3 == 0 &&
        card1 != card2
    }
    
    func match(for other: SetCard) -> Int {
        ((3 - (t0 + other.t0)) % 3) * 1 +
        ((3 - (t1 + other.t1)) % 3) * 3 +
        ((3 - (t2 + other.t2)) % 3) * 9 +
        ((3 - (t3 + other.t3)) % 3) * 27
    }
}
