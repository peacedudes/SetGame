//
//  Style.swift
//  SetGame2
//
//  Created by robert on 2/4/22.
//

import SwiftUI


struct Style {
    static let tick = 0.5
    static let cardDealDuration = tick
    static let totalDealDuration = 3.0
    
    static let cardAspectRatio = 0.618
    static let colors = [Color("green"), Color("blue"), Color("red")]
    static let shapeBgColor = Color("shapeBackground")
    static let shapeLineWidth = CGFloat(2)
    static let cardCornerRadius = CGFloat(8)
    
    static let deckRotation = -90.0
    static let discardRotation = -15.0

    static let deckSlide = 4.0 // messy pile maximum x and y offset
    static let deckSlip = 5.0 // messy pile maximum rotational offset (degrees)
    // TODO: This is like a global dependency. Is it better to split up?
    
    static let whisper = (Voice.named("whisper") != nil) ? "whisper" : "samantha"
}
