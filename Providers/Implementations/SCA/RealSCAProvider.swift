//
//  RealSCAProvider.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 08.03.26.
//

///
///  Thin SCAGateway implementation that delegates to MockSCAServer.
///  In production, this class would be replaced with a real gateway
///  that makes actual HTTP calls. The protocol contract stays the same.
///

import Foundation
import SCACore

@MainActor
public final class RealSCAProvider: SCAProvider {
    
    public let server: MockSCAServer
    
    public init(server: MockSCAServer) {
        self.server = server
    }
    
    public func startChallenge(
        for operation: ChallengeReason,
        context: ChallengeContext?
    ) async throws -> SCAChallenge {
        try await simulateNetworkDelay()
        return try server.createChallenge(for: operation, context: context)
    }
    
    public func verify(proof: AuthenticationProof) async throws -> VerificationStepResult {
        try await simulateNetworkDelay()
        return try server.verifyProof(proof)
    }
    
    public func sendOTP(method: AuthenticationMethod, challengeId: String) async throws {
        try await simulateNetworkDelay()
        try server.sendOTP(method: method, challengeId: challengeId)
    }
    
    public func refreshAuthentication(using refreshToken: String) async throws -> AuthenticationResult {
        try await simulateNetworkDelay()
        return try server.refreshToken(refreshToken)
    }
    
    public func registerTrustedDevice(deviceId: String) async throws {
        try await simulateNetworkDelay()
        server.registerTrustedDevice(deviceId: deviceId)
    }
    
    public func revokeTrustedDevice(deviceId: String) async throws {
        try await simulateNetworkDelay()
        server.revokeTrustedDevice(deviceId: deviceId)
    }
    
    public func logout() async throws {
        try await simulateNetworkDelay()
        server.logout()
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64(server.config.networkDelay * 1_000_000_000))
    }
}
