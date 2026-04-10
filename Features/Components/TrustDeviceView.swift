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
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(.green.gradient.opacity(0.15))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "iphone.badge.checkmark")
                    .font(.system(size: 42))
                    .foregroundStyle(.green.gradient)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 28)
            
            VStack(spacing: 8) {
                Text("Trust This Device?")
                    .font(.title2.bold())
                
                Text("Skip SMS verification next time you sign in from this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 10) {
                Button {
                    onAccept()
                } label: {
                    Text("Trust Device")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.green.gradient, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                
                Button {
                    onDecline()
                } label: {
                    Text("Not Now")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
