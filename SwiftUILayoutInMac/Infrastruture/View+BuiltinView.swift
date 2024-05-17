//
//  View+BuiltinView.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import SwiftUI

protocol View_ {
    associatedtype Body: View_
    
    var body: Body { get }
    
    // for debugging
    associatedtype SwiftUIView: View
    var swiftUI: SwiftUIView { get  }
}

typealias RenderingContext = CGContext

struct ProposedSize {
    var width: CGFloat?
    var height: CGFloat?
}

extension ProposedSize {
    init(_ cgSize: CGSize) {
        self.init(width: cgSize.width, height: cgSize.height)
    }
    
    var orMax: CGSize {
        CGSize(width: width ?? .greatestFiniteMagnitude, height: height ?? .greatestFiniteMagnitude)
    }
    
    var orDefault: CGSize {
        CGSize(width: width ?? 10, height: height ?? 10)
    }
}

protocol BuiltinView {
    func render(context: RenderingContext, size: CGSize)
    func size(proposed: ProposedSize) -> CGSize
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat?
    typealias Body = Never
}

extension View_ where Body == Never {
      var body: Never { fatalError("This should never be called") }
}

extension Never: View_ {
   typealias Body = Never
    
    var swiftUI: Never { fatalError("This should never be called") }
}

// We will have two step process.
// 1) Layout pass to get the correct size
// 2) Render pass to render
// 3) ProposedSize is not really for rendering but for layout step

extension View_ {
    func _customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        if let builtin = self as? BuiltinView {
            return builtin.customAlignment(for: alignment, in: size)
        } else {
            return body._customAlignment(for: alignment, in: size)
        }
    }
    
    // For render it is not proposed size but the size at which it has to render.
    // Proposed size is for the layout pass
    func _render(context: RenderingContext, size: CGSize) {
        // ultimately we need to render so this will be a built in view
        // but we can recursively call body.render for all the views we write
        
        if let builtin = self as? BuiltinView {
            builtin.render(context: context, size: size)
        } else {
            body._render(context: context, size: size)
        }
    }
    
    func _size(propsed: ProposedSize) -> CGSize {
        if let buildin = self as? BuiltinView {
            return buildin.size(proposed: propsed)
        } else {
            return body._size(propsed: propsed)
        }
    }
}

extension RenderingContext {
    func align(_ childSize: CGSize, in parentSize: CGSize, alignment: Alignment_) {
        
        let parentPoint = alignment.point(for: parentSize)
        let childPoint = alignment.point(for: childSize)
        
        translateBy(x: parentPoint.x - childPoint.x, y: parentPoint.y - childPoint.y)
    }
}
