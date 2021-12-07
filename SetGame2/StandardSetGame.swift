//
//  StandardSetGame.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

//import Foundation
import SwiftUI

// TODO verify, remove or revise
struct Style {
    static let tick = 2.5
    
    /// height / width
    static let cardAspectRatio = 0.618
    
    static let colors = [Color("green"), Color("blue"), Color("red")]
    static let shapeBgColor = Color("shapeBackground")
    //    static let shapes = [DiamondView, TildeView, OvalView]
    
    static let shapeLineWidth = CGFloat(2)
//    static let cardFace = Color("cardFace")
    static let cardFaceSelected = Color("cardFaceSelected")
//    static let maxDeckHeight = CGFloat(100)
    
    static var gradientStart: Color { .green }
    static var gradientEnd: Color { .red }
    static var fill = LinearGradient(
        gradient: Gradient(colors: [gradientStart, gradientEnd]),
        startPoint: UnitPoint(x: 0, y: 0.5),
        endPoint: UnitPoint(x: 0.9, y: 0.5)
    )
}

enum shape {
    case diamond
    case oval
    case tilde
}

class StandardSetGame: ObservableObject {
    
    @Published private var model = SetGame()
    var cards: [SetCard] { model.cards }
    var score: Int { model.score }
    
    var isMatchedSet: Bool { model.isMatchedSet }
    var isMisMatchedSet: Bool { model.selectedCards.count == 3 && !isMatchedSet }
    
    // MARK: - Intents
    func newGame() {
        model = SetGame()
        deal(model.minimumCardsToShow)
    }
    
    func choose(_ card: SetCard) {
        model.choose(card)
    }
    
    func hint() {
        
    }

    func shuffle() {
        model.shuffle()
    }
    
    func deal(_ count: Int) {
        model.deal(count)
    }
}
