//
//  ShapeHelper.swift
//  SetGame2
//
//  Created by robert on 12/3/21.
//

import SwiftUI


// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
// MARK - Stroke and fill a shape
extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
 
// Alternate version, nearly the same
//extension Shape {
//    // https://stackoverflow.com/questions/56786163/swiftui-how-to-draw-filled-and-stroked-shape
//    /// fills and strokes a shape
//    public func fill<Fill:ShapeStyle,  Stroke: ShapeStyle>(_ fillContent: Fill, strokeBorder: Stroke, lineWidth: CGFloat = 1) -> some View {
//        ZStack {
//            self.fill(fillContent)
//            self.stroke(strokeBorder, lineWidth: lineWidth)
//        }
//    }
//}

/// Convert UIBezier() to Shape, scaling to fit
struct ScaledBezier: Shape {
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-uibezierpath-and-cgpath-in-swiftui
    // modified to take arbitrary sized svg images; not just unit sized ones
    let bezierPath: UIBezierPath

    func path(in rect: CGRect) -> Path {
        let path = Path(bezierPath.cgPath)
        let drawnRect = path.boundingRect
        
        // Figure out how much tp resize path in order to fill the space without clipping
        let multiplier = min(rect.width / drawnRect.width, rect.height / drawnRect.height)
        // Create an affine transform that uses the multiplier for both dimensions equally.
        let scale = CGAffineTransform(scaleX: multiplier, y: multiplier)
        let translate = CGAffineTransform(translationX: -drawnRect.minX * multiplier, y: -drawnRect.minY * multiplier)
        // Apply that scale and send back the result.
        return path.applying(scale).applying(translate)
    }
}

extension Color {
    // TODO: make draw stripes instead
    // generate a Color stripe pattern
    var stripes: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: Array(repeating: [ self, self, self,
                                           .clear, Style.shapeBgColor, Style.shapeBgColor, Style.shapeBgColor,
                                           Style.shapeBgColor, Style.shapeBgColor, Style.shapeBgColor, Style.shapeBgColor,
                                           Style.shapeBgColor, Style.shapeBgColor, Style.shapeBgColor, Style.shapeBgColor],
                              count: 8) .flatMap { $0 }),
            startPoint: .leading, endPoint: .trailing)
    }
}
