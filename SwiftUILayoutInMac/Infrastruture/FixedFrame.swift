//
//  FixedFrame.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI

struct FixedFrame<Content: View_>: View_, BuiltinView {
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment_
    var content: Content
    
    // If there is a fixed size then that's the size proposed to child and it also reports that size to parent
    // Optimization if there is a fixed size we don't need to ask child for it's size
    func size(proposed: ProposedSize) -> CGSize {
        let childSize = content._size(propsed: ProposedSize(width: width ?? proposed.width, height: height ?? proposed.height))
        return CGSize(width: width ?? childSize.width, height: height ?? childSize.height)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(propsed: ProposedSize(size))
        
        context.align(childSize, in: size, alignment: alignment)
        content._render(context: context, size: childSize)
        
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(width: width, height: height, alignment: alignment.swiftUI)
    }
}


extension View_ {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment_ = .center) -> some View_ {
        FixedFrame(width: width, height: height, alignment: alignment, content: self)
    }
}

struct FixedSize<Content: View_>: View_, BuiltinView {
    var content: Content
    var horizontal: Bool
    var vertical: Bool
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
    }
    
    func size(proposed p: ProposedSize) -> CGSize {
        var proposed = p
        if horizontal { proposed.width = nil }
        if vertical { proposed.height = nil }
        return content._size(propsed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.fixedSize(horizontal: horizontal, vertical: vertical)
    }
}

extension View_ {
    func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> some View_ {
        FixedSize(content: self, horizontal: horizontal, vertical: vertical)
    }
}
