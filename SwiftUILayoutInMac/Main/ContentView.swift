//
//  ContentView.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 06/02/24.
//

import SwiftUI
import Foundation


// Ellipse -> Overlay (Geomtry Reader -> Text) -> Border -> Frame -> Border -> Frame -> Border

// we call render on fixed frame and then that calculates size for the child
// but what we want is size and use that size to render our view
func render<V: View_>(view: V, size: CGSize) -> Data {
    // system size given initially
  
    return CGContext.pdf(size: size) { context in
        view
            .frame(width: size.width, height: size.height)
            .border(NSColor.green, width: 2)
            ._render(context: context, size: size)
    }
}

struct ContentView: View {
    @State var opacity: Double = 0.5
    @State var width: CGFloat = 300
    @State var minWidth: (CGFloat, enabled: Bool) = (100, true)
    @State var maxWidth: (CGFloat, enabled: Bool) = (400, true)
    
    let size = CGSize(width: 800, height: 400 )
    
    // overlay first renders its child in this case it is Ellipse and then it lays other view on top of it
    // it takes the child size and proposes to the other view.
    // That's why you can use a gemoetry reader inside an overlay to measure the underlying view
    var sample: some View_ {
        Ellipse_()
            .frame(width: 150)
            .frame(
                minWidth: minWidth.enabled ?  minWidth.0.rounded() : nil,
                maxWidth: maxWidth.enabled ? maxWidth.0.rounded() : nil
            )
            .overlay(GeometryReader_(content: { size in
                Text_("\(Int(size.width)) x \(Int(size.height))")
            }))
            .border(NSColor.blue, width: 2)
            .frame(width: width.rounded(), height: 300, alignment: .center)
            .border(NSColor.yellow, width: 2)
    }

    
    var body: some View {
        VStack {
            ZStack {
                Image(nsImage: NSImage(data: render(view: sample, size: size))!)
                    .opacity(1)
                sample.swiftUI.frame(width: size.width, height: size.height)
                    .opacity(opacity)
            }
            
            Slider(value: $opacity, in: 0...1)
            HStack {
                Text("Width \(width.rounded())")
                Slider(value: $width, in: 0...600)
            }
            
            HStack {
                Text("Min Width \(minWidth.0.rounded())")
                Slider(value: $minWidth.0, in: 0...600)
                Toggle("", isOn: $minWidth.enabled)
            }
            
            HStack {
                Text("Max Width \(maxWidth.0.rounded())")
                Slider(value: $maxWidth.0, in: 0...600)
                Toggle("", isOn: $maxWidth.enabled)
            }
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



