//
//  DebugFloatingButton.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 26.03.26.
//

import SwiftUI

struct DebugFloatingButton: View {
    
    @Binding var showPanel: Bool
    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 40, y: 120)
    @State private var isDragging = false
    
    private let buttonSize: CGFloat = 48
    
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .overlay {
                Image(systemName: "ant.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)
            }
            .frame(width: buttonSize, height: buttonSize)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        position = value.location
                    }
                    .onEnded { value in
                        isDragging = false
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            position = snappedPosition(for: value.location)
                        }
                    }
            )
            .onTapGesture {
                showPanel = true
            }
            .animation(.easeInOut(duration: 0.15), value: isDragging)
    }
    
    private func snappedPosition(for point: CGPoint) -> CGPoint {
        let screen = UIScreen.main.bounds
        let margin: CGFloat = 8 + buttonSize / 2
        let midX = screen.width / 2
        
        let snappedX = point.x < midX ? margin : screen.width - margin
        let clampedY = min(max(point.y, margin + 50), screen.height - margin - 50)
        
        return CGPoint(x: snappedX, y: clampedY)
    }
}
