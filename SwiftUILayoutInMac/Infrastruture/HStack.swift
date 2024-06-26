//
//  HStack.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 11/02/24.
//

import SwiftUI

@propertyWrapper
final class LayoutState<A> {
    var wrappedValue: A
    
    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}

struct HStack_: View_, BuiltinView {
  
    let children: [AnyView_]
    var alignment: VerticalAlignment_ = .center
    var spacing: CGFloat? = 0
    @LayoutState var sizes: [CGSize] = []
    
    func render(context: RenderingContext, size: CGSize) {
        let stackY = alignment.alginmentID.defaultValue(in: size )
          
        var currentX: CGFloat = 0
        
        for idx in children.indices {
            let child = children[idx]
            let childSize = sizes[idx]
            let childY = alignment.alginmentID.defaultValue(in: childSize)
            context.saveGState()
            context.translateBy(x: currentX, y: stackY - childY)
            child.render(context: context, size: childSize)
            context.restoreGState()
            currentX += childSize.width
        }
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        layout(proposed: proposed)
        let width = sizes.reduce(0) { $0 + $1.width }
        let height = sizes.reduce(0) { max($0, $1.height) }
         
        return CGSize(width: width, height: height)
    }
    
    var swiftUI: some View {
        HStack(alignment: alignment.swiftUI, spacing: spacing) {
            ForEach(children.indices, id: \.self) { idx in
                children[idx].swiftUI
            }
         }
    }
       
    func layout(proposed: ProposedSize)  {
        let flexibility: [CGFloat] = children.map { child in
            let lower = child.size(proposed: ProposedSize(width: 0, height: proposed.height)).width
            let upper = child.size(proposed: ProposedSize(width: .greatestFiniteMagnitude, height: proposed.height)).width
            return upper - lower
        }
        
        var remainingIndices = children.indices.sorted { l, r in
            flexibility[l] < flexibility[r]
        }
        
        var remainingWidth = proposed.width! // TODO
        var sizes: [CGSize] = Array(repeating: .zero, count: children.count)
        
        while !remainingIndices.isEmpty {
            let width = remainingWidth / CGFloat(remainingIndices.count)
            let idx = remainingIndices.removeFirst()
            let child = children[idx]
            let childSize = child.size(proposed: ProposedSize(width: width, height: proposed.height))
            sizes[idx] = childSize
            remainingWidth -= childSize.width
             
            if remainingWidth < 0 {
                remainingWidth = 0
            }
        }
        
        self.sizes = sizes
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        fatalError("TODO")
    }
}

class AnyViewBase: BuiltinView {
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        fatalError()
    }
    
    func render(context: RenderingContext, size: CGSize) {
        fatalError()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        fatalError()
    }
}

final class AnyViewImpl<V: View_>: AnyViewBase {
    let view: V
    
    init(_ view: V) {
        self.view = view
    }
    
    override func render(context: RenderingContext, size: CGSize) {
        view._render(context: context, size: size)
    }
    
    override func size(proposed: ProposedSize) -> CGSize {
        view._size(propsed: proposed)
    }
    
    override func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        view._customAlignment(for: alignment, in: size)
    }
}

// Erases the type we are wrapping
struct AnyView_: View_, BuiltinView {
    
    let swiftUI: AnyView
    let impl: AnyViewBase
    
    init<V: View_>(_ view: V) {
        self.swiftUI = AnyView(view.swiftUI)
        self.impl = AnyViewImpl(view)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        impl.render(context: context, size: size)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        impl.size(proposed: proposed)
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        impl.customAlignment(for: alignment, in: size)
    }
    
}


