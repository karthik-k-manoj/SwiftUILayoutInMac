//
//  ContentView.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 06/02/24.
//

import SwiftUI
import Foundation

var sample: some View_ {
    Ellipse_()
        .frame(width: 200, height: 100)
        .border(NSColor.blue, width: 2)
        .frame(width: 300, height: 300, alignment: .topLeading)
        .border(NSColor.yellow, width: 2)
}


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
    
    let size = CGSize(width: 600, height: 400 )
    
    var body: some View {
        VStack {
            ZStack {
                Image(nsImage: NSImage(data: render(view: sample, size: size))!)
                    .opacity(1)
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



