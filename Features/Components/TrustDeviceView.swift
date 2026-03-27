//
//  TrustDeviceView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SwiftUI

struct TrustDeviceView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "iphone.badge.checkmark")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("Trust This Device?")
                .font(.title2.bold())
            
            Text("You won't need to verify with SMS next time.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("Trust Device", action: onAccept)
                .buttonStyle(.borderedProminent)
            
            Button("Not Now", action: onDecline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
