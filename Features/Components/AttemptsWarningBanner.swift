//
//  AttemptsWarningBanner.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SwiftUI

struct AttemptsWarningBanner: View {
    let attemptsRemaining: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: attemptsRemaining > 0
                  ? "exclamationmark.triangle.fill"
                  : "lock.fill")
                .foregroundStyle(attemptsRemaining > 0 ? .yellow : .red)
            
            Text(attemptsRemaining > 0
                 ? "\(attemptsRemaining) attempt\(attemptsRemaining == 1 ? "" : "s") remaining"
                 : "Account locked — try again later")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .padding(.top, 8)
    }
}
