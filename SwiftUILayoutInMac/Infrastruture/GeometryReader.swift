//
//  GeometryReader.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 08/02/24.
//

import SwiftUI

struct GeometryReader_<Content: View_>: View_, BuiltinView {
    let content: (CGSize) -> Content
    
    func render(context: RenderingContext, size: CGSize) {
        let child = content(size)
        let childSize = child._size(propsed: size)
        context.saveGState()
        context.align(childSize, in: size, alignment: .center)
        child._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        proposed
    }
     
    var swiftUI: some View {
        GeometryReader { proxy in
            content(proxy.size).swiftUI
        }
    }
}
