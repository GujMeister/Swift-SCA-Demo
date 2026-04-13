//
//  OTPEntryView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SwiftUI
import SCACore

struct OTPEntryView: View {
    let method: AuthenticationMethod?
    let onSubmit: (String) -> Void
    let onCancel: () -> Void
    let onResend: () -> Void
    let cooldown: Int
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(.blue.gradient.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: method?.iconName ?? "lock.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 24)
            
            VStack(spacing: 6) {
                Text("Verification Code")
                    .font(.title3.bold())
                
                Text("Always 123456 for demo reasons")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                
                Text(method?.description ?? "Enter the 6-digit code")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            TextField("000000", text: $code)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title.monospaced().weight(.semibold))
                .tracking(8)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .onChange(of: code) { _, newValue in
                    if newValue.count > 6 {
                        code = String(newValue.prefix(6))
                    }
                }
            
            Button {
                onSubmit(code)
            } label: {
                Text("Verify")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
                    .opacity(code.count < 6 ? 0.5 : 1)
            }
            .disabled(code.count < 6)
            .padding(.horizontal)
            
            Button {
                onResend()
            } label: {
                if cooldown > 0 {
                    Text("Resend in \(cooldown)s")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Resend code")
                        .foregroundStyle(.blue)
                }
            }
            .font(.subheadline.weight(.medium))
            .disabled(cooldown > 0)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}
