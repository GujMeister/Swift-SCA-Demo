//
//  InfoView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 10/04/2026.
//

import SwiftUI
import ProviderLayer
import SCACore

struct InfoView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: InfoViewModel
    
    init(
        onSelect: @escaping (MockUserProfile) -> Void,
        onColdStart: @escaping (MockUserProfile) -> Void
    ) {
        _viewModel = State(wrappedValue: InfoViewModel(
            parameters: .init(onSelect: onSelect, onColdStart: onColdStart),
            dependencies: .resolve()
        ))
    }
    
    var body: some View {
        NavigationStack {
            List {
                informationText
                userSelectionSectionView
                coldStartSectionView
                userInfoSectionView
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await viewModel.process(.refreshPreconditions)
            }
        }
    }
}

// MARK: - Sections

private extension InfoView {
    var informationText: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.blue)
                
                Text("Pick any test user below to auto-fill their credentials. Scroll down to see what authentication methods each one has enrolled.")
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Testing biometrics?")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Enable Face ID in the simulator first:\nFeatures → Face ID → Enrolled, otherwise it'll always skip biometrics as it's not `available` on the device")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 4)
    }
    
    var userSelectionSectionView: some View {
        Section {
            ForEach(MockUserProfile.allProfiles, id: \.email) { profile in
                Button {
                    Task { await viewModel.process(.selectedProfile(profile)) }
                    dismiss()
                } label: {
                    profileRow(for: profile)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Available Test Users")
        } footer: {
            Text("Tap a user to auto-fill their credentials")
                .font(.caption)
        }
    }
    
    var coldStartSectionView: some View {
        Section {
            if viewModel.canColdStart {
                ForEach(MockUserProfile.allProfiles.filter { !$0.inherenceMethods.isEmpty }, id: \.email) { profile in
                    Button {
                        Task { await viewModel.process(.triggeredColdStart(profile)) }
                        dismiss()
                    } label: {
                        coldStartRow(for: profile)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                coldStartPreconditionsView
            }
        } header: {
            Text("Simulate Cold Start")
        } footer: {
            Text("Auto-login using trusted device + biometrics, no password needed")
                .font(.caption)
        }
    }
    
    var coldStartPreconditionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cold start unavailable")
                        .font(.callout.weight(.semibold))
                    
                    if !viewModel.state.isDeviceTrusted {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Text("Device trust is off — enable it in the Debug Panel")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if !viewModel.state.isBiometricsAvailable {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Text("Biometrics not enrolled — Simulator → Features → Face ID → Enrolled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
    
    var userInfoSectionView: some View {
        Section("User Details") {
            ForEach(MockUserProfile.allProfiles, id: \.email) { profile in
                VStack(alignment: .leading, spacing: 14) {
                    basicInfo(profile)
                    credentials(profile)
                    methods(profile)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    func basicInfo(_ profile: MockUserProfile) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 44, height: 44)
                
                Text(String(profile.displayName.prefix(1)))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.headline)
                Text(profile.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(profile.allMethods.count) methods")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.quaternary.opacity(0.5), in: Capsule())
        }
    }
    
    func credentials(_ profile: MockUserProfile) -> some View {
        VStack(spacing: 8) {
            credentialRow(
                icon: "envelope.fill",
                tint: .blue,
                label: "Email",
                value: profile.email
            )
            credentialRow(
                icon: "key.fill",
                tint: .orange,
                label: "Password",
                value: profile.password
            )
        }
        .padding(12)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    func methods(_ profile: MockUserProfile) -> some View {
        if !profile.knowledgeMethods.isEmpty {
            methodGroup(
                title: "Knowledge",
                icon: "brain.head.profile",
                tint: .purple,
                methods: profile.knowledgeMethods
            )
        }
        
        if !profile.possessionMethods.isEmpty {
            methodGroup(
                title: "Possession",
                icon: "iphone.radiowaves.left.and.right",
                tint: .blue,
                methods: profile.possessionMethods
            )
        }
        
        if !profile.inherenceMethods.isEmpty {
            methodGroup(
                title: "Inherence",
                icon: "faceid",
                tint: .green,
                methods: profile.inherenceMethods
            )
        }
    }
}

// MARK: - Helper Views

private extension InfoView {
    func profileRow(for profile: MockUserProfile) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 44, height: 44)
                
                Text(String(profile.displayName.prefix(1)))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(profile.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(8)
                .background(.quaternary.opacity(0.5), in: Circle())
        }
        .padding(.vertical, 6)
    }
    
    func coldStartRow(for profile: MockUserProfile) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.green.gradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "faceid")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Trusted device + Face ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "bolt.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
                .padding(8)
                .background(.green.opacity(0.15), in: Circle())
        }
        .padding(.vertical, 6)
    }
    
    func methodGroup(
        title: String,
        icon: String,
        tint: Color,
        methods: [AuthenticationMethod]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            
            FlowLayout(spacing: 6) {
                ForEach(methods, id: \.identifier) { method in
                    Text(method.displayName)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(tint.opacity(0.12), in: Capsule())
                        .foregroundStyle(tint)
                }
            }
        }
    }
    
    func credentialRow(
        icon: String,
        tint: Color,
        label: String,
        value: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(tint)
                .frame(width: 16)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption.monospaced())
                .foregroundStyle(.primary)
        }
    }
}
