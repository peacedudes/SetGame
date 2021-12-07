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
//            .padding(1)
            .cardify(faceColor: faceColor)
//            .padding(2)
        
    }
}

struct StandardCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StandardCardView(card: SetCard(id: 1))
            StandardCardView(card: SetCard(id: 32))
            StandardCardView(card: SetCard(id: 60))
            StandardCardView(card: SetCard(id: 66))

            StandardCardView(card: SetCard(id: 75))

            StandardCardView(card: SetCard(id: 77))
        }
    }
}

extension SetCard : View {
    var number: Int { t3 }
    var shape: Int { t2 }
    var fill: Int { t1 }
    var baseColor: Color { Style.colors[t0] }
    
    var fillColor: Color {
        switch fill {
        case 2: return baseColor
        case 1: return baseColor.opacity(0.4)
        default: return Color("shapeBackground")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
//                Spacer()
                VStack {
                    ForEach(0..<number + 1) { _ in
                        Group {
                            if fill == 1 {
                                switch (shape) {
                                case 2: OvalView(fill: baseColor.stripes, stroke: baseColor)
                                case 1: TildeView(fill: baseColor.stripes, stroke: baseColor)
                                default: DiamondView(fill: baseColor.stripes, stroke: baseColor)
                                }
                            } else {
                                switch (shape) {
                                case 2: OvalView(fill: fillColor, stroke: baseColor)
                                case 1: TildeView(fill: fillColor, stroke: baseColor)
                                default: DiamondView(fill: fillColor, stroke: baseColor)
                                }
                            }
                        }
                        .frame(maxWidth: geometry.size.height / 3.0 / Style.cardAspectRatio)
                    }
                }
                .padding(.vertical, 4)
//                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
