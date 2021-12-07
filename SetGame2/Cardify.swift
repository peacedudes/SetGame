//
//  Cardify.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var faceColor: Color
    var cornerRaidus = CGFloat(4)
    var lineWidth = Style.shapeLineWidth

    var rotation: Double = 0.0 // degrees

    var animatableData : Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: cornerRaidus)
            if rotation <  90 {
                shape.foregroundColor(faceColor)
                shape.strokeBorder(lineWidth: lineWidth)
            } else {
                shape.fill(.green)
//                switch theme.back {
//                case .color(let color): shape.fill(color)
//                case .linear(let linearGradient): shape.fill(linearGradient)
//                }
            }
            content
                .opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation),
                          axis: (x: 0, y: 1, z: 0))
    }
}


extension View {
    func cardify(faceColor: Color = Color("faceColor")) -> some View {
        modifier(Cardify(faceColor: faceColor))
    }
}



struct Cardify_Previews: PreviewProvider {
    static var previews: some View {
        Text("boo!")
            .cardify()
            .padding(40)
    }
}
