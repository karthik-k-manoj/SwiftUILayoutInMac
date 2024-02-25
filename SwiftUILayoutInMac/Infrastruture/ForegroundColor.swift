//
//  ForegroundColor.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 15/02/24.
//

import SwiftUI

struct ForegroundColor<Content: View_>: View_, BuiltinView {
    var content: Content
    var color: NSColor
    
    func render(context: RenderingContext, size: CGSize) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        content._render(context: context, size: size)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(propsed: proposed)
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        content._customAlignment(for: alignment, in: size)
    }
    
    var swiftUI: some View {
        content.swiftUI.foregroundColor(Color(color))
    }
}

extension View_ {
    func foregroundColor(color: NSColor) -> some View_ {
        ForegroundColor(content: self, color: color)
    }
}
