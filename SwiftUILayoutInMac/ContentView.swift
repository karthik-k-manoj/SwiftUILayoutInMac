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
}

typealias RenderingContext = CGContext
typealias ProposedSize = CGSize


protocol BuiltinView {
    func render(context: RenderingContext, size: ProposedSize)
    typealias Body = Never
}

extension View_ where Body == Never {
      var body: Never { fatalError("This should never be called") }
}

extension Never: View_ {
   typealias Body = Never
}

// We will have two step process.
// 1) Layout pass to get the correct size
// 2) Render pass to render
// 3) ProposedSize is not really for rendering but for layout step

extension View_ {
    func _render(context: RenderingContext, size: ProposedSize) {
        // ultimately we need to render so this will be a built in view
        // but we can recursively call body.render for all the views we write
        
        if let builtin = self as? BuiltinView {
            builtin.render(context: context, size: size)
        } else {
            body._render(context: context, size: size)
        }
    }
}

protocol Shape_ {
    func path(in rect: CGRect) -> CGPath
}

struct ShapeView<S: Shape_>: BuiltinView, View_ {
    var shape: S
    
    func render(context: RenderingContext, size: ProposedSize) {
        context.saveGState()
        context.setFillColor(NSColor.red.cgColor)
        context.addPath(shape.path(in: CGRect(origin: .zero, size: size)))
        context.fillPath()
        context.restoreGState()
    }
}

struct Rectangle_: Shape_ {
    func path(in rect: CGRect) -> CGPath {
        CGPath(rect: rect, transform: nil)
    }
}

let sample = ShapeView(shape: Rectangle_())

func render<V: View_>(view: V) -> Data {
    let size = CGSize(width: 400, height: 600)
    return CGContext.pdf(size: size) { context in
        view._render(context: context, size: size)
    }
}

struct ContentView: View {
    var body: some View {
        Image(nsImage: NSImage(data: render(view: sample))!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// A (body) -> B (body) -> C (body) -> BuiltInVIew
