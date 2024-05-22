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
    var minWidth: CGFloat? // this affects the outcome of the size methid
    var idealWidth: CGFloat? // This is used for the child when proposed width is nil
    var maxWidth: CGFloat?  // this affects the outcome of the size methid
    var minHeight: CGFloat?  // this affects the outcome of the size methid
    var idealHeight: CGFloat?  // This is used for the child when proposed width is nil
    var maxHeight: CGFloat?  // this affects the outcome of the size methid
    var alignment: Alignment_
    var content: Content
    
    // If there is a fixed size then that's the size proposed to child and it also reports that size to parent
    // Optimization if there is a fixed size we don't need to ask child for it's size
    
    func size(proposed: ProposedSize) -> CGSize {
        var _proposed = ProposedSize(
            width: proposed.width ?? idealWidth,
            height: proposed.height ?? idealHeight
        ).orDefault
        
        if let min = minWidth, min > _proposed.width {
            _proposed.width = min
         //   print("Proposed with in min", _proposed.width )
        }
        
        if let max = maxWidth, max < _proposed.width {
            _proposed.width = max
           // print("Proposed with in min", _proposed.width )
        }
        
        var result = content._size(propsed: ProposedSize(_proposed))
        
        if let m = minWidth {
           // print("Min Width: \(minWidth), Result Width: \(result.width), Propsoed Width: \(_proposed.width)")
            result.width = max(m, min(result.width, _proposed.width))
            print("Result width in min", result.width)
        }

        // if have only maxWidth then clamp content width to max width

        if let m = maxWidth {
            //print("Max Width: \(maxWidth), Result Width: \(result.width), Propsoed Width: \(_proposed.width)")
            result.width = min(m, max(result.width, _proposed.width))
        }
        return result
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        fatalError()
    }
    
  //  100   200
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        let childSize = content._size(propsed: ProposedSize(size))
        
        fatalError() 
       // context.align(childSize, in: size, alignment: alignment)
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


/*
 Flexible frame has a lot of features. When the parent proposes a size to it, it check if the proposed size width and height are non optionals.
 If optionals they use ideal height and ideal weight. If they are also optional then they use the default size of 10 X 10.
 
 Now if min and max are set, then this value is constrainted to be within this range. This size is then proposed to the child.
 Child returns it's size (content size) but since min and max are already set the constrainted proposed size is returned as the reported size
 
 
 if only min is set then proposed size would be clamped between min size and content size
 if only max is set then proposed size would be clamped between content size and max size
 */
