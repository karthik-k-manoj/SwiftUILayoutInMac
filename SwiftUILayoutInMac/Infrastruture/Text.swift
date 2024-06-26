//
//  Text.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import SwiftUI

struct Text_: View_, BuiltinView {
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    let font = NSFont.systemFont(ofSize: 16)
    
    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: NSColor.white
        ]
    }
    
    var framesetter: CTFramesetter {
        let str = NSAttributedString(string: text, attributes: attributes)
        return CTFramesetterCreateWithAttributedString(str)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(),
            nil,
            proposed.orMax,
            nil
        )
    }
    
    func render(context: RenderingContext, size: CGSize) {
        let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(), path, nil)
        context.saveGState()
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        return nil
    }
    
    var swiftUI: some View {
        Text(text).font(Font(font))
    }
}
