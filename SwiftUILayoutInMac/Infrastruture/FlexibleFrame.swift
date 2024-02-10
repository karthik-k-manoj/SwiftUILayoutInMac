//
//  FlexibleFrame.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 09/02/24.
//

import Foundation
import SwiftUI

// Flexible frame also takes account of content size
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
            print("Proposed with in min", _proposed.width )
        }
        
        if let max = maxWidth, max < proposed.width {
            _proposed.width = max
            print("Proposed with in min", _proposed.width )
        }
        
        var result = content._size(propsed: _proposed)
        
        if let m = minWidth {
            print("Min Width: \(minWidth), Result Width: \(result.width), Propsoed Width: \(_proposed.width)")
            result.width = max(m, min(result.width, _proposed.width))
            print("Result width in min", result.width)
        }

        // if have only maxWidth then clamp content width to max width

        if let m = maxWidth {
            print("Max Width: \(maxWidth), Result Width: \(result.width), Propsoed Width: \(_proposed.width)")
            result.width = min(m, max(result.width, _proposed.width))
        }
        return result
    }
    
  //  100   200
    
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
