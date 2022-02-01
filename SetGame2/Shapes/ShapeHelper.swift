//
//  ShapeHelper.swift
//  SetGame2
//
//  Created by robert on 12/3/21.
//

import SwiftUI


// MARK - Stroke and fill a shape
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}

// This seems to be needed for completeness somehow
extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
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

func diamond() -> some Shape {
    Diamond()
}

func tilde() -> some Shape {
    ScaledBezier(bezierPath: .tilde)
}

func oval() -> some Shape {
    Capsule()
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
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

/// Convert UIBezier() to Shape, scaling to fit
struct ScaledBezier: Shape {
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-uibezierpath-and-cgpath-in-swiftui
    // modified to take arbitrary sized svg images; not just unit sized ones
    let bezierPath: UIBezierPath

    func path(in rect: CGRect) -> Path {
        let path = Path(bezierPath.cgPath)
        let drawnRect = path.boundingRect
        
        /// How much to resize path to fill space without clipping
        let multiplier = min(rect.width / drawnRect.width, rect.height / drawnRect.height)
        let scale = CGAffineTransform(scaleX: multiplier, y: multiplier)
        let translate = CGAffineTransform(translationX: -drawnRect.minX * multiplier, y: -drawnRect.minY * multiplier)
        return path.applying(scale).applying(translate)
    }
}

/// Convert UIBezier() to Shape, scaling to fit

extension Color {
    // TODO: this /draw/ stripes instead
    /// generate a Color stripe pattern
    var stripes: LinearGradient {
        let bg = Style.shapeBgColor
        return LinearGradient(
            gradient: Gradient(
                colors: Array(
                    repeating: [
                        self,
                        bg, bg, bg, bg,
                        self ],
                    count: 9) .flatMap { $0 }),
            startPoint: .leading,
            endPoint: .trailing)
    }
}
