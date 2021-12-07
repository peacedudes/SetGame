//
//  DiamondView.swift
//  SetGame2
//
//  Created by robert on 12/3/21.
//

import SwiftUI

struct DiamondView<Fill: ShapeStyle, Stroke: ShapeStyle>: View {
    let fill: Fill
    let stroke: Stroke
    
    var body: some View {
        GeometryReader { geometry in
            let bounds = geometry.size.phiSized
            diamondPath(in: bounds)
                .fill(fill, strokeBorder: stroke, lineWidth: Style.shapeLineWidth)
                .frame(width: bounds.width, height: bounds.height, alignment: .bottom)
        }
        .padding(Style.shapeLineWidth / 2)
    }
    
    func diamondPath(in rect: CGRect) -> Path {
        Path { path in
            path.move(to:    CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

struct DiamondView_Previews: PreviewProvider {
    static var previews: some View {
        DiamondView(fill: Style.fill, stroke: Color.blue)
        DiamondView(fill: Color.blue.stripes, stroke: Color.blue)
    }
}

extension CGSize {
    /// bounds of largest horizontal golden ratio rect that fits, centered
    var phiSized: CGRect {
        let newWidth = min(width, height / Style.cardAspectRatio)
        let newHeight = newWidth * Style.cardAspectRatio
        let left = (width - newWidth) / 2
        let top = (height - newHeight) / 2
        return CGRect(x: left, y: top, width: newWidth, height: newHeight)
    }
}
