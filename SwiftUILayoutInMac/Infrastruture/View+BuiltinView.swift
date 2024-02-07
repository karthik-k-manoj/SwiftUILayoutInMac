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
typealias ProposedSize = CGSize


protocol BuiltinView {
    func render(context: RenderingContext, size: CGSize)
    func size(proposed: ProposedSize) -> CGSize
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
