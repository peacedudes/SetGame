//
//  OvalView.swift
//  SetGame2
//
//  Created by robert on 12/3/21.
//

import SwiftUI

struct OvalView<Fill: ShapeStyle, Stroke: ShapeStyle>: View {

    var fill: Fill// = Color.blue as! Fill
    var stroke: Stroke = Color.black as! Stroke
    
    var body: some View {
        GeometryReader { geometry in
            let bounds = geometry.size.phiSized
            Capsule()
                .fill(fill, strokeBorder: stroke, lineWidth: Style.shapeLineWidth)
                .frame(width: bounds.width, height: bounds.height, alignment: .bottom)
                .position(x: bounds.midX, y: bounds.midY)
        }
        .padding(Style.shapeLineWidth / 2)
    }
}

struct OvalView_Previews: PreviewProvider {
    
    static var previews: some View {
        OvalView(fill: Color.green.stripes, stroke: Color.blue)
        OvalView(fill: Style.fill, stroke: Color.blue)

    }
}

