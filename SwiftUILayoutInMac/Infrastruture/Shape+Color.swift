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

extension Shape_ {
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

struct AnyShape: Shape {
    let _path: (CGRect) -> CGPath
    
    init<S: Shape_>(shape: S) {
        _path = shape.path(in:)
    }
    
    func path(in rect: CGRect) -> Path {
        Path(_path(rect))
    }
}

struct ShapeView<S: Shape_>: BuiltinView, View_ {
    var shape: S
    var color: NSColor = .red
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.addPath(shape.path(in: CGRect(origin: .zero, size: size)))
        context.fillPath()
        context.restoreGState()
    }
    
    // Shape in SwiftUI is very felxible. They report the proposed size
    func size(proposed: ProposedSize) -> CGSize {
        proposed
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
