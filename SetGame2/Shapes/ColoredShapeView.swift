//
//  ColoredShapeView.swift
//  SetGame2
//
//  Created by robert on 12/27/21.
//

import SwiftUI

enum FillStyle {
    case color(Color)
    case linearGradient(LinearGradient)
}

struct ColoredShapeView<S: Shape>: View {
    let shape: ()->S
    let color: Color
    let fill: FillStyle
    
    var body: some View {
        GeometryReader { geometry in
            let goldenBounds = geometry.size.phiSized
            Group {
                switch fill {
                case .color(let fillColor):
                    shape().fill(fillColor, strokeBorder: color, lineWidth: Style.shapeLineWidth)
                case .linearGradient(let gradient):
                    shape().fill(gradient, strokeBorder: color, lineWidth: Style.shapeLineWidth)
                }
            }
            .frame(width: goldenBounds.width, height: goldenBounds.height, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding(Style.shapeLineWidth / 2)
    }
}

struct ColoredShapeView_Previews: PreviewProvider {
    
    static var gradientStart: Color { .blue }
    static var gradientEnd: Color { .red }
    static var fill = LinearGradient(
        gradient: Gradient(colors: [gradientStart, gradientEnd]),
        startPoint: UnitPoint(x: 0, y: 0.5),
        endPoint: UnitPoint(x: 0.9, y: 0.5)
    )
    
    static var previews: some View {
        VStack {
            ColoredShapeView(shape: diamond, color: Color.blue, fill: FillStyle.linearGradient(Color.blue.stripes))
            ColoredShapeView(shape: tilde, color: Color.blue, fill: FillStyle.color(Color.green))
            ColoredShapeView(shape: oval, color: Color.red, fill: FillStyle.linearGradient(Color.red.stripes))
        }
    }
}
