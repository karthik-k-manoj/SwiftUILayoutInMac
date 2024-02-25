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
        
        let t = translation(for: content, in: size, childSize: childSize, alignment: alignment)
        context.translateBy(x: t.x, y: t.y)
        content._render(context: context, size: childSize)
        
        context.restoreGState()
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        let childSize = content._size(propsed: ProposedSize(size))
        if let customX = content._customAlignment(for: alignment, in: childSize) {
            let t = translation(for: content, in: size, childSize: childSize, alignment: self.alignment)
            return t.x + customX
        }
        
        return nil
    }
    
    var swiftUI: some View {
        content.swiftUI.frame(width: width, height: height, alignment: alignment.swiftUI)
    }
}


extension View_ {
    func translation<V: View_>(for childView: V, in parentSize: CGSize, childSize: CGSize, alignment: Alignment_) -> CGPoint {
        let parentPoint = alignment.point(for: parentSize)
        var childPoint = alignment.point(for: childSize)
        
        if let customX = childView._customAlignment(for: alignment.horizontal, in: childSize) {
            childPoint.x = customX
        }
        
        // TODO vertical axis
        return CGPoint(x: parentPoint.x - childPoint.x, y: parentPoint.y - childPoint.y)
    }
    
    func translation<V: View_>(for sibiling: V, in size: CGSize, sibilingSize: CGSize, alignment: Alignment_) -> CGPoint {
        var selfPoint = alignment.point(for: size)
        var sibilingPoint = alignment.point(for: sibilingSize)
        
        if let customX = self._customAlignment(for: alignment.horizontal, in: sibilingSize) {
            selfPoint.x = customX
        }
        
        if let customX = sibiling._customAlignment(for: alignment.horizontal, in: sibilingSize) {
            sibilingPoint.x = customX
        }
        
        // TODO vertical axis
        return CGPoint(x: selfPoint.x - sibilingPoint.x, y: selfPoint.y - sibilingPoint.y)
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
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
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
