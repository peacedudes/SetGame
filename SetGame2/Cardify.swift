//
//  Cardify.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var faceColor: Color
    var isFaceUp: Bool {
        didSet {
            // TODO: Maybe this isn't needed
            rotation = isFaceUp ? 0 : 180
        }
    }
    var cornerRaidus = CGFloat(6)
    var lineWidth = Style.shapeLineWidth
    
    // CS193P trick; use 3d rotation for face up/down transitions
    var rotation: Double // degrees
    var animatableData : Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(faceColor: Color, isFaceUp: Bool) {
        self.faceColor = faceColor
        self.isFaceUp = isFaceUp
        rotation = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: cornerRaidus)
            if rotation < 90 {
                shape.foregroundColor(faceColor)
            } else {
                Image("setBack")
                    .resizable()
                    .clipShape(shape)
            }
            shape.strokeBorder(lineWidth: lineWidth)
            content.opacity(rotation < 90 ? 1 : 0)
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
