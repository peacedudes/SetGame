//
//  Cardify.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var faceColor: Color
    var cornerRaidus = Style.cardCornerRadius
    var lineWidth = Style.shapeLineWidth

    // CS193P trick; use 3d rotation for face up/down transitions
    var rotation: Double // degrees
    var isFaceShowing: Bool { rotation < 90 }
    
    var animatableData : Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(faceColor: Color, isFaceUp: Bool) {
        self.faceColor = faceColor
        rotation = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: cornerRaidus)
            if isFaceShowing {
                shape.foregroundColor(faceColor)
            } else {
                Image("setBack")
                    .resizable()
                    .clipShape(shape)
            }
            shape.strokeBorder(lineWidth: lineWidth)
            content.opacity(isFaceShowing ? 1 : 0)
        }
        .aspectRatio(Style.cardAspectRatio, contentMode: .fit)
        .rotation3DEffect(Angle.degrees(rotation), axis: (x: 0, y: 1, z: 0))
    }
}


extension View {
    func cardify(faceColor: Color = Color("faceColor"),
                 isFaceUp: Bool = true) -> some View {
        modifier(Cardify(faceColor: faceColor, isFaceUp: isFaceUp))
    }
}

struct Cardify_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("boo!").cardify()
            Text("boo2!") .cardify(isFaceUp: false)
        }
        .padding(40)
    }
}
