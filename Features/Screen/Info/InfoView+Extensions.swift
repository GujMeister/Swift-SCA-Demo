//
//  InfoView+Extensions.swift
//  Application
//
//  Created by Luka Gujejiani on 10/04/2026.
//

import SwiftUI

extension InfoView {
    struct FlowLayout: Layout {
        var spacing: CGFloat = 8
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let maxWidth = proposal.width ?? .infinity
            var height: CGFloat = 0
            var rowWidth: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if rowWidth + size.width > maxWidth {
                    height += rowHeight + spacing
                    rowWidth = size.width + spacing
                    rowHeight = size.height
                } else {
                    rowWidth += size.width + spacing
                    rowHeight = max(rowHeight, size.height)
                }
            }
            return CGSize(width: maxWidth, height: height + rowHeight)
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            var x = bounds.minX
            var y = bounds.minY
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > bounds.maxX {
                    x = bounds.minX
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
    }
}
