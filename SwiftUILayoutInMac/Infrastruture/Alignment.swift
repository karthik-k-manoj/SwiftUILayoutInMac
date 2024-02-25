//
//  Alignment.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI

extension Alignment_ {
    func point(for size: CGSize) -> CGPoint {
        let x = horizontal.alginmentID.defaultValue(in: size)
        let y = vertical.alginmentID.defaultValue(in: size)
        return CGPoint(x: x, y: y)
    }
}

struct Alignment_ {
    var horizontal: HorizontalAlignment_
    var vertical: VerticalAlignment_
    
    var swiftUI: Alignment {
        Alignment(horizontal: horizontal.swiftUI, vertical: vertical.swiftUI)
    }
    
    static let leading = Self(horizontal: .leading, vertical: .center)
    static let center = Self(horizontal: .center, vertical: .center)
    static let topLeading = Self(horizontal: .leading, vertical: .top)
    static let topTrailing = Self(horizontal: .trailing, vertical: .top)
}

struct HorizontalAlignment_ {
    var alginmentID: AlignmentID_.Type
    var swiftUI: HorizontalAlignment
    
    static let leading = Self(alginmentID: HLeading.self, swiftUI: .leading)
    static let trailing = Self(alginmentID: HTrailing.self, swiftUI: .trailing)
    static let center = Self(alginmentID: HCenter.self, swiftUI: .center)
}

struct VerticalAlignment_ {
    var alginmentID: AlignmentID_.Type
    var swiftUI: VerticalAlignment
    
    static let top = Self(alginmentID: VTop.self, swiftUI: .top)
    static let center = Self(alginmentID: VCenter.self, swiftUI: .center)
}

protocol AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat
}

enum VTop: AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat {
        context.height
    }
}

enum VCenter: AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat {
        context.height / 2
    }
}

enum HLeading: AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat {
        0
    }
}

enum HCenter: AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat {
        context.width / 2
    }
}

enum HTrailing: AlignmentID_ {
    static func defaultValue(in context: CGSize) -> CGFloat {
        context.width
    }
}

struct CustomHAlignmentGuide<Content: View_>: View_, BuiltinView {
    var content: Content
    var alignment: HorizontalAlignment_
    var computeValue: (CGSize) -> CGFloat
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(propsed: proposed)
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        if alignment.alginmentID == self.alignment.alginmentID {
            return computeValue(size)
        }
        
        return content._customAlignment(for: alignment, in: size)
    }
    
    var swiftUI: some View {
        content.swiftUI.alignmentGuide(alignment.swiftUI) {
            computeValue(CGSize(width: $0.width, height: $0.height))
        }
    }
}

extension View_ {
    func alignmentGuide(for alignment: HorizontalAlignment_, computeValue: @escaping (CGSize) -> CGFloat) -> some View_ {
        CustomHAlignmentGuide(content: self, alignment: alignment, computeValue: computeValue)
    }
}
