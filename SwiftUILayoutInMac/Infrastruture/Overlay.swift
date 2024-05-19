//
//  Overlay.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI


// Proposed Size

// Reported Size

// From parent to the last child will have the size method called
// Parent proposes one size, child reports some size


// Overlay first renders it's child and then it lays the view on top of it, it takes the child size
// and propose to the over lay view. That's why you can use geometery reader to measure the underlying view

// What is the size of an overlay is the size of it's content . That size is passed to the overlay view
// as the propsez size

struct Overlay<Content: View_, O: View_>: View_, BuiltinView {
   
    let content: Content
    let overlay: O
    let alignment: Alignment_
    
    // size is the size which we get to render
    func render(context: RenderingContext, size: CGSize) {
        // first child content but in backgeound it will be background and then content
        content._render (context: context, size: size)
        // renders content with size (whihc is reported size of the overlay i.e. content own size
        
        // This object then proposes size (content size) to it's overlay view
        let childSize = overlay._size(propsed: ProposedSize(size))
        
        let t = content.translation(for: overlay, in: size, sibilingSize: childSize, alignment: alignment)
        context.translateBy(x: t.x, y: t.y)
        context.saveGState() 
    
        //context.align(childSize, in: size, alignment: alignment)
        overlay._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
    }
    
    
    // Here the parent of over lay will propose some size
    // It uses that proposed size this size to the content
    // but overlay returns the reported size of the content
    // which is passes to the render method of over lay
    
    func size(proposed: ProposedSize) -> CGSize { 
        content._size(propsed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.overlay(overlay.swiftUI, alignment: alignment.swiftUI)
    }
}

// Overlay is a view that takes the overlay view
extension View_ {
    func overlay<O: View_>(_ overlay: O, alignment: Alignment_ = .center) -> some View_ {
        Overlay(content: self, overlay: overlay, alignment: alignment)
    }
}
