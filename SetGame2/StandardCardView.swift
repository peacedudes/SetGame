//
//  StandardCardView.swift
//  SetGame2
//
//  Created by robert on 12/5/21.
//

import SwiftUI

struct StandardCardView: View {
    let card: SetCard
    let faceColor: Color

    init(card: SetCard, faceColor: Color = Color("cardFace")) {
        self.card = card
        self.faceColor = faceColor
    }

    var body: some View {
        card
            .cardify(faceColor: faceColor, isFaceUp: card.state == .inPlay)
            .padding(Style.shapeLineWidth)
    }
}

// MARK: -- Card draws itself
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
        // TODO: how to write something more like, (shape: [diamond, tilde, oval][shape],..)
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
                    StandardCardView(card: SetCard(id: 1))
                    StandardCardView(card: SetCard(id: 32))
                    StandardCardView(card: SetCard(id: 60))
                    StandardCardView(card: SetCard(id: 79))
                    StandardCardView(card: SetCard(id: 75))
                    StandardCardView(card: SetCard(id: 77))
                }
                HStack {
                StandardCardView(card: SetCard(id: 55))
                StandardCardView(card: SetCard(id: 34))
                StandardCardView(card: SetCard(id: 81))
                }
            }
            .preferredColorScheme(.dark)
            VStack {
                HStack {
                    StandardCardView(card: SetCard(id: 1))
                    StandardCardView(card: SetCard(id: 32))
                    StandardCardView(card: SetCard(id: 60))
                    StandardCardView(card: SetCard(id: 79))
                    StandardCardView(card: SetCard(id: 75))
                    StandardCardView(card: SetCard(id: 77))
                }
                HStack {
                    StandardCardView(card: SetCard(id: 55))
                    StandardCardView(card: SetCard(id: 34))
                    StandardCardView(card: SetCard(id: 81))
                }
            }
        }
    }
}
