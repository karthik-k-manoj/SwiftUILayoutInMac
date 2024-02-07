//
//  ContentView.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 06/02/24.
//

import SwiftUI
import Foundation

extension CGContext {
    static func pdf(size: CGSize, render: (CGContext) -> ()) -> Data {
        let pdfData = NSMutableData()
        let consumer = CGDataConsumer(data: pdfData)!
        var mediaBox = CGRect(origin: .zero, size: size)
        let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
        pdfContext.beginPage(mediaBox: &mediaBox)
        render(pdfContext)
        pdfContext.endPage()
        pdfContext.closePDF()
        return pdfData as Data
    }
}

protocol View_ {
    associatedtype Body: View_
    
    var body: Body { get }
    
    // for debugging
    associatedtype SwiftUIView: View
    var swiftUI: SwiftUIView { get  }
}

typealias RenderingContext = CGContext
typealias ProposedSize = CGSize


protocol BuiltinView {
    func render(context: RenderingContext, size: CGSize)
    func size(proposed: ProposedSize) -> CGSize
    typealias Body = Never
}

extension View_ where Body == Never {
      var body: Never { fatalError("This should never be called") }
}

extension Never: View_ {
   typealias Body = Never
    
    var swiftUI: Never { fatalError("This should never be called") }
}

// We will have two step process.
// 1) Layout pass to get the correct size
// 2) Render pass to render
// 3) ProposedSize is not really for rendering but for layout step

extension View_ {
    func _render(context: RenderingContext, size: CGSize) {
        // ultimately we need to render so this will be a built in view
        // but we can recursively call body.render for all the views we write
        
        if let builtin = self as? BuiltinView {
            builtin.render(context: context, size: size)
        } else {
            body._render(context: context, size: size)
        }
    }
    
    func _size(propsed: ProposedSize) -> CGSize {
        if let buildin = self as? BuiltinView {
            return buildin.size(proposed: propsed)
        } else {
            return body._size(propsed: propsed)
        }
        
    }
}

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

struct FixedFrame<Content: View_>: View_, BuiltinView {
    var width: CGFloat?
    var height: CGFloat?
    var content: Content
    
    // If there is a fixed size then that's the size proposed to child and it also reports that size to parent
    // Optimization if there is a fixed size we don't need to ask child for it's size
    func size(proposed: ProposedSize) -> CGSize {
        let childSize = content._size(propsed: ProposedSize(width: width ?? proposed.width, height: height ?? proposed.height))
        return CGSize(width: width ?? childSize.width, height: height ?? childSize.height)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(propsed: size)
        
        let x = (size.width - childSize.width) / 2
        let y = (size.height - childSize.height) / 2
        
        context.translateBy(x: x, y: y)
        content._render(context: context, size: childSize)
        
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(width: width, height: height)
    }
}

struct Border<Content: View_>: View_, BuiltinView {
    var color: NSColor
    var width: CGFloat
    var content: Content
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(propsed: proposed )
    }
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.stroke(CGRect(origin: .zero, size: size).insetBy(dx: width/2, dy: width/2), width: width)
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.border(Color(color), width: width)
    }
}

extension View_ {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View_ {
        FixedFrame(width: width, height: height, content: self)
    }
    
    func border(_ color: NSColor, width: CGFloat) -> some View_ {
        Border(color: color, width: width, content: self)
    }
}

var sample: some View_ {
    Ellipse_()
        .frame(width: 200, height: 100)
        .border(NSColor.blue, width: 2)
        .frame(width: 300, height: 50)
        .border(NSColor.yellow, width: 2)
}


// we call render on fixed frame and then that calculates size for the child
// but what we want is size and use that size to render our view
func render<V: View_>(view: V, size: CGSize) -> Data {
    // system size given initially
  
    return CGContext.pdf(size: size) { context in
        view
            .frame(width: size.width, height: size.height)
            ._render(context: context, size: size)
    }
}

struct ContentView: View {
    @State var opacity: Double = 0.5
    
    let size = CGSize(width: 600, height: 400 )
    
    var body: some View {
        VStack {
            ZStack {
                Image(nsImage: NSImage(data: render(view: sample, size: size))!)
                    .opacity(1 - opacity)
                sample.swiftUI.frame(width: size.width, height: size.height)
                    .opacity(opacity)
            }
            
            Slider(value: $opacity, in: 0...1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// A (body) -> B (body) -> C (body) -> BuiltInVIew


// Fixed frame is a modifer why because it modifies a content view i.e. it wraps content view

// inside fixed frame view. If there is a width or height it proposes this to the child view

// ignoring the proposed size given by fixed frame parent. Child then decides to take or not

// Fixed frame view reports width or height it has or it takes size from the child and not proposed size

// Fixed frame view does not have origin rather it has alignment

// In terms of rendering frame centers content by default if not alignemnt is set
