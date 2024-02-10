//
//  Border.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI

struct Border<Content: View_>: View_, BuiltinView {
    var color: NSColor
    var width: CGFloat
    var content: Content
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(propsed: proposed)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.stroke(CGRect(origin: .zero, size: size).insetBy(dx: width/2, dy: width/2), width: width)
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.border(Color(color), width: width)
    }
}

extension View_ {
    func border(_ color: NSColor, width: CGFloat) -> some View_ {
        Border(color: color, width: width, content: self)
    }
}
