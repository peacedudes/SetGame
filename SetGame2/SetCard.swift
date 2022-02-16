//
//  SetCard.swift
//  SetGame2
//
//  Created by robert on 2/2/22.
//

import Foundation

/**
 SetCards have four traits, each of three possible values.
 There are 81 unique cards, or 3 * 3 * 3 * 3
 It can be  helpful to think of the values as single digit base3 numbers, and the traits as place holder value names

 If we use ids 0...80, we can directly derive the traits from the id.
 */
struct SetCard: Identifiable, Equatable {
    /// 0...80 (or 0000...2222 in base 3).
    let id: Int
    var isSelected = false
    var isFaceUp = false

    enum State {
        case undealt, inPlay, discarded
    }
    var state = State.undealt

    init(id rawId: Int, isFaceUp: Bool = false) {
        // Todo: is it better to Fail if id >= 81 or negative?
        id = abs(rawId) % 81
        self.isFaceUp = isFaceUp
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
    // It turns out this is true when the sum of each trait (0, 1, 2) equals (0 or 3 or 6).
    var isT0Matched: Bool { map { $0.t0 } .reduce(0, +) % 3 == 0 }
    var isT1Matched: Bool { map { $0.t1 } .reduce(0, +) % 3 == 0 }
    var isT2Matched: Bool { map { $0.t2 } .reduce(0, +) % 3 == 0 }
    var isT3Matched: Bool { map { $0.t3 } .reduce(0, +) % 3 == 0 }

    var isMatchedSet: Bool {
        count == 3 &&
        self[0].id != self[1].id &&
        isT0Matched && isT1Matched && isT2Matched && isT3Matched
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
