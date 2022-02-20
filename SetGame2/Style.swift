//
//  Style.swift
//  SetGame2
//
//  Created by robert on 2/4/22.
//

import SwiftUI


// TODO: This has become a global dependency. Is it better to split up and moved to where it's used?
struct Style {
    static let tick = 0.50
    static let cardDealDuration = tick
    static let totalDealDuration = 2.0
    
    static let cardAspectRatio = 0.618
    static let colors = [Color("green"), Color("blue"), Color("red")]
    static let shapeBgColor = Color("shapeBackground")
    static let shapeLineWidth = CGFloat(2)
    static let cardCornerRadius = CGFloat(8)
    
    /// undealt card pile resting orientation
    static let deck = StackOrientation(rotation: -80, maxSlip: 4, maxSlide: 3)
    /// discard card pile resting orientation
    static let discard = StackOrientation(rotation: -15, maxSlip: 15, maxSlide: 10)

    static let whisper = (Voice.named("whisper") != nil) ? "whisper" : "samantha"
}
