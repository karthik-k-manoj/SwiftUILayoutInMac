//
//  Shape+Color.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI

protocol Shape_: View_ {
    func path(in rect: CGRect) -> CGPath
}

// Since `Shape_` is ` View_` it needs to conformt to `swiftUI: View`. Here `AnyShape` is `Shape` is `View`
extension Shape_ {
    // For ease of conveniece `Shape_` is a `View_`. It calls the body from render method
    // body is a `ShapeView` by default color is `.red` and it draws the path with filled color as red
    // `SwiftUI` does default color as foreground color
    var body: some View_ {
        ShapeView(shape: self)
    }
    
    var swiftUI: AnyShape {
        AnyShape(shape: self)
    }
}

extension NSColor: View_ {
    var body: some View_ {
        ShapeView(shape: Rectangle_(), color: self)
    }
    
    var swiftUI: some View {
        Color(self)
    }
}

// type eraser
struct AnyShape: Shape {
    let _path: (CGRect) -> CGPath
    
    init<S: Shape_>(shape: S) {
        _path = shape.path(in:)
    }
    
    // This is the requirment for `Shape`
    func path(in rect: CGRect) -> Path {
        Path(_path(rect))
    }
}

/*
 in swiftUI we deal with shapes such as rectangle, circle but internally there is something called
 shape view which does the real action.
 */
struct ShapeView<S: Shape_>: BuiltinView, View_ {
    var shape: S
    var color: NSColor = .red
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        nil
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.addPath(shape.path(in: CGRect(origin: .zero, size: size)))
        context.fillPath()
        context.restoreGState()
    }
    
    // Shape in SwiftUI is very felxible. They report the proposed size
    func size(proposed: ProposedSize) -> CGSize {
        proposed.orMax
    }
    
    var swiftUI: some View {
        AnyShape(shape: shape)
    }
}

struct Rectangle_: Shape_ {
    func path(in rect: CGRect) -> CGPath {
        CGPath(rect: rect, transform: nil)
    }
}

struct Ellipse_ : Shape_ {
    func path(in rect: CGRect) -> CGPath {
        CGPath(ellipseIn: rect, transform: nil)
    }
}
