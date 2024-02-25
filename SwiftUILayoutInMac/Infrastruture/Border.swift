//
//  Border.swift
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 07/02/24.
//

import Foundation
import SwiftUI

struct BorderShape: Shape_{
    var width: CGFloat
    
    func path(in rect: CGRect) -> CGPath {
        let path = CGPath(rect: rect.insetBy(dx: width/2, dy: width/2), transform: nil)
        return path.copy(strokingWithWidth: width, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
    }
}

extension View_ {
    func border(_ color: NSColor, width: CGFloat) -> some View_ {
        overlay(BorderShape(width: width).foregroundColor(color: color))
    }
}
