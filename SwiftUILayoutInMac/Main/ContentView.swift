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
            //.border(NSColor.green, width: 2)
            ._render(context: context, size: size)
    }
}

extension View_ {
    var measured: some View_ {
        overlay(GeometryReader_(content: { size in
            Text_("\(Int(size.width))")
        }))
    }
}

// In swift UI ellipse is 150 wide and reported size is 300
// In our implementaion ellipse is 150 and reported size is 150
struct ContentView: View {
    @State var opacity: Double = 0.5
    @State var width: CGFloat = 300
    @State var height: CGFloat = 300
    @State var minWidth: (CGFloat, enabled: Bool) = (100, true)
    @State var maxWidth: (CGFloat, enabled: Bool) = (400, true)
    
    let size = CGSize(width: 800, height: 400 )
    
    // overlay first renders its child in this case it is Ellipse and then it lays other view on top of it
    // it takes the child size and proposes to the other view.
    // That's why you can use a gemoetry reader inside an overlay to measure the underlying view
    var sample: some View_ {
        Rectangle_()
            .foregroundColor(color: NSColor.yellow)
            .frame(width: 200, height: 200)
            .alignmentGuide(for: .center, computeValue: { size in
                size.width
            })
            .border(NSColor.white, width: 2.0)
            .frame(width: 300, height: 300, alignment: .center)
            //.border(NSColor.yellow, width: 2)
    }
    
    // 300 is propsed width and ellipse is 150 wide
    // flexibile frame stays at 150
    
    // if we propise size that is smaller  60 and min width is 100 it will be capped to 100
    // we propose 100 to fixed frame but it propose 150 to ellipse. Ellipse says I am 150
    // Fixed frame says I am 150 Then flexible frame ignores child size of 150 but I am gonna be 100
    // We propose 60 but child has 100 as min width and it should be 100 but we could also think
    // I only specifed min width and the content says I am 150 why does it come 150
    //
    
    // 100 > 60 so width should be 100
    // I have only specifier minwidth as 100 content says is 150 then why does flexibale frame become 150
    // Flexible frame has the tendency to always become what is proposed that is kind higher priority
    // Since we only proposed 60, 100 is closer to 60 so 100 is selected
    
    // But if proposed width is larger it will not go beyond content size
    // In the absence of maxWidth value, content size becomes maxWidth somehow. i.e. it ranges from
    // minWidth to content size width max value
    
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
                Text("Height \(height.rounded())")
                Slider(value: $height, in: 0...600)
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



