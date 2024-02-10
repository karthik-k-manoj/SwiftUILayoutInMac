//
//  FlexibleFrame.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 09/02/24.
//

import Foundation
import SwiftUI

struct FlexibleFrame<Content: View_>: View_, BuiltinView {
    var minWidth: CGFloat?
    var idealWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var idealHeight: CGFloat?
    var maxHeight: CGFloat?
    var alignment: Alignment_
    var content: Content
    
    // If there is a fixed size then that's the size proposed to child and it also reports that size to parent
    // Optimization if there is a fixed size we don't need to ask child for it's size
    func size(proposed: ProposedSize) -> CGSize {
        var _proposed = proposed
        if let min = minWidth, min > proposed.width {
            _proposed.width = min
        }
        
        if let max = maxWidth, max < proposed.width {
            _proposed.width = max
        }
        
        let childSize = content._size(propsed: _proposed)
        return childSize
    }
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(propsed: size)
        
        context.align(childSize, in: size, alignment: alignment)
        content._render(context: context, size: childSize)
        
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment.swiftUI)
    }
}


extension View_ {
    func frame(minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment_ = .center) -> some View_ {
        FlexibleFrame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment, content: self)
    }
}
