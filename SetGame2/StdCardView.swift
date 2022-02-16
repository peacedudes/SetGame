//
//  StdCardView.swift
//  SetGame2
//
//  Created by robert on 12/5/21.
//

import SwiftUI

struct StdCardView: View {
    let card: SetCard
    let faceColor: Color

    init(card: SetCard, faceColor: Color = Color("cardFace")) {
        self.card = card
        self.faceColor = faceColor
    }

    var body: some View {
        card
            .cardify(faceColor: faceColor, isFaceUp: card.isFaceUp)
            .padding(Style.shapeLineWidth)
        
    }
}

// MARK: -- Make Card draw itself
extension SetCard : View {
    var number: Int { t3 }
    var shape: Int { t2 }
    var baseColor: Color { Style.colors[t1] }
    var fillStyle: FillStyle {
        switch t0 {
        case 2: return .color(baseColor)
        case 1: return .linearGradient(baseColor.stripes)
        default: return .color(Color("shapeBackground"))
        }
    }
    
    var t0Name: String { ["open", "striped", "solid"][t0] }
    var t1Name: String { ["green", "blue", "red"][t1] }
    var t2Name: String { ["diamond", "squiggle", "oval"][t2] + (t3 > 0 ? "s" : "") }
    var t3Name: String { ["single", "pair", "triplet"][t3] }
    
    var cardName: String { ["\(t3 + 1)", t0Name, t1Name, t2Name].joined(separator: " ") }

    
//    var isInPile: Bool { state != .inPlay }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                Spacer(minLength: 2)
                ForEach(0..<number + 1) { _ in
                    shapeView
                        .frame(maxWidth: geometry.size.height / 3 / Style.cardAspectRatio)
                }
                Spacer(minLength: 2)
            }
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)

        }
    }
    
    @ViewBuilder
    var shapeView: some View {
        // TODO: find something more like [diamond, tilde, oval][shape]
        switch shape {
        case 2: ColoredShapeView(shape: oval, color: baseColor, fill: fillStyle)
        case 1: ColoredShapeView(shape: tilde, color: baseColor, fill: fillStyle)
        default: ColoredShapeView(shape: diamond, color: baseColor, fill: fillStyle)
        }
    }
}

struct StandardCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                HStack {
                    StdCardView(card: SetCard(id: 1))
                    StdCardView(card: SetCard(id: 32, isFaceUp: true))
                    StdCardView(card: SetCard(id: 60, isFaceUp: true))
                    StdCardView(card: SetCard(id: 79, isFaceUp: true))
                    StdCardView(card: SetCard(id: 75, isFaceUp: true))
                    StdCardView(card: SetCard(id: 77))
                }
                HStack {
                    StdCardView(card: SetCard(id: 55, isFaceUp: true))
                    StdCardView(card: SetCard(id: 34))
                    StdCardView(card: SetCard(id: 81, isFaceUp: true))
                }
            }
            .preferredColorScheme(.dark)
            VStack {
                HStack {
                    StdCardView(card: SetCard(id: 1))
                    StdCardView(card: SetCard(id: 32, isFaceUp: true))
                    StdCardView(card: SetCard(id: 60, isFaceUp: true))
                    StdCardView(card: SetCard(id: 79, isFaceUp: true))
                    StdCardView(card: SetCard(id: 75, isFaceUp: true))
                    StdCardView(card: SetCard(id: 77))
                }
                HStack {
                    StdCardView(card: SetCard(id: 55, isFaceUp: true))
                    StdCardView(card: SetCard(id: 34))
                    StdCardView(card: SetCard(id: 81, isFaceUp: true))
                }
            }
        }
    }
}
