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
        let childSize = child._size(propsed: ProposedSize(size))
        context.saveGState()
        fatalError()
       // context.align(childSize, in: size, alignment: .center)
        child._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        nil
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        proposed.orDefault
    }
     
    var swiftUI: some View {
        GeometryReader { proxy in
            content(proxy.size).swiftUI
        }
    }
}
