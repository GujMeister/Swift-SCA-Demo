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
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: reason.iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("Choose verification method")
                    .font(.headline)
                
                ForEach(methods, id: \.identifier) { method in
                    Button {
                        onSelect(method)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: method.iconName)
                                .font(.title3)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.displayName)
                                    .font(.body.weight(.medium))
                                Text(method.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .tint(.primary)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
