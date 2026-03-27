//
//  DebugPanelView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 26.03.26.
//

import SwiftUI

struct DebugPanelView: View {
    
    @Bindable var controller: DebugController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                
                // MARK: - Active User
                
                Section("Active User") {
                    if let name = controller.activeUserDisplayName,
                       let email = controller.activeUserEmail {
                        LabeledContent("User", value: "\(name) (\(email))")
                        LabeledContent("Methods", value: controller.activeUserMethods.joined(separator: ", "))
                    } else {
                        Text("No active user")
                            .foregroundStyle(.secondary)
                    }
                    
                    if !controller.failedAttempts.isEmpty {
                        ForEach(Array(controller.failedAttempts), id: \.key) { email, count in
                            LabeledContent("Failed: \(email)", value: "\(count)")
                        }
                        Button("Reset Failed Attempts", role: .destructive) {
                            controller.resetFailedAttempts()
                        }
                    }
                }
                
                // MARK: - Auth Tokens
                
                Section("Auth Tokens") {
                    if let token = controller.currentAuthToken {
                        LabeledContent("Auth Token") {
                            Text(String(token.suffix(12)))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        LabeledContent("Auth Token", value: "None")
                    }
                    
                    if let refresh = controller.currentRefreshToken {
                        LabeledContent("Refresh Token") {
                            Text(String(refresh.suffix(12)))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        LabeledContent("Refresh Token", value: "None")
                    }
                    
                    Button("Force Expire Tokens", role: .destructive) {
                        Task { await controller.forceExpireTokens() }
                    }
                }
                
                // MARK: - Device Trust
                
                Section("Device Trust") {
                    Toggle("Device Trusted", isOn: Binding(
                        get: { controller.isDeviceTrusted },
                        set: { _ in Task { await controller.toggleDeviceTrust() } }
                    ))
                    
                    if let days = controller.trustDaysRemaining {
                        LabeledContent("Expires in", value: "\(days) days")
                    }
                }
                
                // MARK: - Server Configuration
                
                Section("Server Configuration") {
                    VStack(alignment: .leading) {
                        Text("Network Delay: \(String(format: "%.1fs", controller.networkDelay))")
                        Slider(
                            value: $controller.networkDelay,
                            in: 0...5,
                            step: 0.5
                        )
                    }
                    
                    Stepper(
                        "Min Factors: \(controller.minimumFactors)",
                        value: $controller.minimumFactors,
                        in: 1...3
                    )
                    
                    Stepper(
                        "Challenge Expiry: \(controller.challengeExpirationMinutes)m",
                        value: $controller.challengeExpirationMinutes,
                        in: 1...30
                    )
                    
                    Stepper(
                        "Token TTL: \(controller.tokenExpiresIn)s",
                        value: $controller.tokenExpiresIn,
                        in: 10...600,
                        step: 30
                    )
                    
                    Toggle("Issues Refresh Tokens", isOn: $controller.issuesRefreshTokens)
                    
                    Button("Force Expire Challenges", role: .destructive) {
                        controller.forceExpireChallenges()
                    }
                }
                
                // MARK: - Biometrics Simulation
                
                Section("Biometrics Simulation") {
                    Toggle("Biometrics Available", isOn: $controller.biometricsAvailable)
                }
                
                // MARK: - Danger Zone
                
                Section("Danger Zone") {
                    Button("Force Logout", role: .destructive) {
                        controller.logoutUser()
                    }
                }
            }
            .navigationTitle("Debug Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await controller.refresh()
        }
    }
}
