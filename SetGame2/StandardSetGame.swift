//
//  StandardSetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import AVFoundation
import SwiftUI

// TODO verify, remove or revise
struct Style {
//    static let tick = 2.5
    
    /// height / width
//    static let cardAspectRatio = 150.0 / 250.0 //0.618
    static let cardAspectRatio = 15.0 / 25.0
    
    static let colors = [Color("green"), Color("blue"), Color("red")]
    static let shapeBgColor = Color("shapeBackground")
    static let shapeLineWidth = CGFloat(2)
    
    static let whisper = (Voice.named("whisper") != nil) ? "whisper" : "samantha"
}

class StandardSetGame: ObservableObject {
    
    @Published private var model = SetGame()
    var cards: [SetCard] { model.cards }
    var score: Int { model.score }

    @Published private(set) var isHushed = true
    var isMatchedSet: Bool { model.isMatchedSet }
    var isMisMatchedSet: Bool { model.isMisMatchedSet }

    // MARK: - Intents

    func newGame() {
        model = SetGame()
        deal(model.minimumCardsToShow)
    }

    func choose(_ card: SetCard) {
        let before = model.selectedCards.count % 3
        model.choose(card)
        if model.selectedCards.count > before || model.selectedCards.count == 0 {
            provideHint()
        }
    }

    fileprivate func provideHint() {
        if !isHushed, let spokenText = model.feedback {
            if model.hasPlayableMatch(model.selectedCards) {
                spokenText.speak(voice: Voice.named(Style.whisper), rate: 0.8)
            } else {
                spokenText.speak()
            }
        }
    }
    
    func toggleSound() {
        isHushed.toggle()
        if !isHushed {
            provideHint()
        }
    }

    func shuffle() {
        model.shuffle()
    }
    
    func deal(_ count: Int) {
        let previousOutcome = model.outcome
        model.deal(count)
        if previousOutcome != model.outcome {
            provideHint()
        }
    }
}
