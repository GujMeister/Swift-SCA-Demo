//
//  AuthMethodPickerView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SwiftUI
import SCACore

struct MethodPickerView: View {
    let methods: [AuthenticationMethod]
    let reason: ChallengeReason
    let onSelect: (AuthenticationMethod) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.blue.gradient.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: reason.iconName)
                    .font(.system(size: 32))
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 24)
            
            VStack(spacing: 6) {
                Text("Choose Method")
                    .font(.title3.bold())
                
                Text("Pick how you'd like to verify")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 10) {
                ForEach(methods, id: \.identifier) { method in
                    Button {
                        onSelect(method)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: method.iconName)
                                .font(.title3)
                                .foregroundStyle(.blue.gradient)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(method.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(14)
                        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}
