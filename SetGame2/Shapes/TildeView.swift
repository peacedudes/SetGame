//
//  TildeView.swift
//  SetGame2
//
//  Created by robert on 12/3/21.
//

import SwiftUI

struct TildeView<Fill: ShapeStyle, Stroke: ShapeStyle>: View {
    let fill: Fill
    let stroke: Stroke
    
    var body: some View {
        GeometryReader { geometry in
            let golden = geometry.size.phiSized
            ScaledBezier(bezierPath: .tilde)
                .fill(fill, strokeBorder: stroke, lineWidth: Style.shapeLineWidth)
                .frame(width: golden.width, height: golden.height, alignment: .center)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding(Style.shapeLineWidth / 2)
    }
}

struct TildeView_Previews: PreviewProvider {
 
    static var previews: some View {
        TildeView(fill: Color.orange.stripes, stroke: Color.blue)
        TildeView(fill: Style.fill, stroke: Color.purple)
    }
}

extension UIBezierPath {
    // InkScape sketch as svg, converted to shape data by "swiftvg"
    // https://github.com/mike-engel/swiftvg
    static var tilde: UIBezierPath {
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 80.6, y: 69.41))
        shape.addCurve(to: CGPoint(x: 91.13, y: 68.67), controlPoint1: CGPoint(x: 82.85, y: 75.67), controlPoint2: CGPoint(x: 84.28, y: 68.52))
        shape.addCurve(to: CGPoint(x: 117.07, y: 63.87), controlPoint1: CGPoint(x: 97.98, y: 68.82), controlPoint2: CGPoint(x: 115.99, y: 77.55))
        shape.addCurve(to: CGPoint(x: 117.07, y: 54.92), controlPoint1: CGPoint(x: 117.15, y: 60.59), controlPoint2: CGPoint(x: 117.07, y: 58))
        shape.addCurve(to: CGPoint(x: 106.5, y: 57.05), controlPoint1: CGPoint(x: 114.12, y: 52.05), controlPoint2: CGPoint(x: 114.48, y: 56.88))
        shape.addCurve(to: CGPoint(x: 80.8, y: 61.07), controlPoint1: CGPoint(x: 98.53, y: 57.21), controlPoint2: CGPoint(x: 83.06, y: 48.34))
        shape.close()
        return shape
    }
}
