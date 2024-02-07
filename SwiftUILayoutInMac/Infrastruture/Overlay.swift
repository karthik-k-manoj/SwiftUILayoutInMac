//
//  Overlay.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI


struct Overlay<Content: View_, O: View_>: View_, BuiltinView {
    let content: Content
    let overlay: O
    let alignment: Alignment_
    
    // size is the size which we get to render
    func render(context: RenderingContext, size: CGSize) {
        // first child content but in backgeound it will be background and then content
        content._render(context: context, size: size)
        
        let childSize = overlay._size(propsed: size)
        context.saveGState()
        context.align(childSize, in: size, alignment: alignment)
        overlay._render(context: context, size: childSize)
        context.restoreGState()
         
    }
    
    func size(proposed: ProposedSize) -> CGSize { 
        content._size(propsed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.overlay(overlay.swiftUI, alignment: alignment.swiftUI)
    }
}

extension View_ {
    func overlay<O: View_>(_ overlay: O, alignment: Alignment_ = .center) -> some View_ {
        Overlay(content: self, overlay: overlay, alignment: alignment)
    }
}
