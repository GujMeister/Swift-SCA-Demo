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
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: method?.iconName ?? "lock.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text(method?.description ?? "Enter code")
                    .font(.headline)
                
                TextField("Enter 6-digit code", text: $code)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2.monospaced())
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
                Button("Verify") { onSubmit(code) }
                    .disabled(code.count < 6)
                    .buttonStyle(.borderedProminent)
                
                // MARK: - Resend
                
                Button {
                    onResend()
                } label: {
                    if cooldown > 0 {
                        Text("Resend code in \(cooldown)s")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Resend code")
                    }
                }
                .disabled(cooldown > 0)
                .font(.subheadline)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
