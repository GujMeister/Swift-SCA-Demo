//
//  DebugController.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 26.03.26.
//

import Observation
import SCACore
import ProviderLayer
import Foundation

@MainActor
@Observable
public final class DebugController {
    
    // MARK: - Dependencies
    
    @ObservationIgnored
    private let server: MockSCAServer
    
    @ObservationIgnored
    private let storage: SecureStorage
    
    // MARK: - Server Config (local state, synced to server)
    
    public var networkDelay: TimeInterval {
        didSet { server.config.networkDelay = networkDelay }
    }
    
    public var challengeExpirationMinutes: Int {
        didSet { server.config.challengeExpirationMinutes = challengeExpirationMinutes }
    }
    
    public var minimumFactors: Int {
        didSet { server.config.minimumFactors = minimumFactors }
    }
    
    public var issuesRefreshTokens: Bool {
        didSet { server.config.issuesRefreshTokens = issuesRefreshTokens }
    }
    
    public var tokenExpiresIn: Int {
        didSet { server.config.tokenExpiresIn = tokenExpiresIn }
    }
    
    // MARK: - Biometric Simulation
    
    public var biometricsAvailable: Bool = true {
        didSet {
            print("🔧 DEBUG: Biometrics available = \(biometricsAvailable)")
            // TODO: Wire to MockBiometricProvider.simulatedAvailability
        }
    }
    
    // MARK: - Token State
    
    public var currentAuthToken: String?
    public var currentRefreshToken: String?
    
    // MARK: - Device Trust
    
    public var isDeviceTrusted: Bool = false
    public var trustDaysRemaining: Int?
    
    // MARK: - User Info
    
    public var activeUserEmail: String?
    public var activeUserDisplayName: String?
    public var activeUserMethods: [String] = []
    public var failedAttempts: [String: Int] = [:]
    
    // MARK: - Init
    
    public init(server: MockSCAServer, storage: SecureStorage) {
        self.server = server
        self.storage = storage
        
        // Seed from current server config
        self.networkDelay = server.config.networkDelay
        self.challengeExpirationMinutes = server.config.challengeExpirationMinutes
        self.minimumFactors = server.config.minimumFactors
        self.issuesRefreshTokens = server.config.issuesRefreshTokens
        self.tokenExpiresIn = server.config.tokenExpiresIn
    }
    
    // MARK: - Refresh All State
    
    /// Call this every time the panel appears to sync with current reality
    public func refresh() async {
        // Tokens
        currentAuthToken = await storage.getAuthenticationToken()
        currentRefreshToken = await storage.getRefreshToken()
        
        // Device trust
        isDeviceTrusted = await storage.isDeviceTrusted()
        trustDaysRemaining = await storage.getDaysUntilTrustExpiry()
        
        // User info
        activeUserEmail = server.activeUser?.email
        activeUserDisplayName = server.activeUser?.displayName
        activeUserMethods = server.activeUser?.allMethods.map(\.identifier) ?? []
        failedAttempts = server.currentFailedAttempts
        
        // Server config (in case it changed externally)
        networkDelay = server.config.networkDelay
        challengeExpirationMinutes = server.config.challengeExpirationMinutes
        minimumFactors = server.config.minimumFactors
        issuesRefreshTokens = server.config.issuesRefreshTokens
        tokenExpiresIn = server.config.tokenExpiresIn
    }
    
    // MARK: - Device Trust Actions
    
    public func toggleDeviceTrust() async {
        let deviceId = await storage.getDeviceId()
        
        if isDeviceTrusted {
            await storage.clearDeviceTrust()
            server.revokeTrustedDevice(deviceId: deviceId)
        } else {
            try? await storage.markDeviceAsTrusted()
            server.registerTrustedDevice(deviceId: deviceId)
        }
        
        isDeviceTrusted = await storage.isDeviceTrusted()
        trustDaysRemaining = await storage.getDaysUntilTrustExpiry()
        print("🔧 DEBUG: Device trust = \(isDeviceTrusted) (synced to server)")
    }
    
    // MARK: - Token Actions
    
    public func forceExpireTokens() async {
        await storage.clearAuthenticationToken()
        await storage.clearRefreshToken()
        server.logout()
        
        currentAuthToken = nil
        currentRefreshToken = nil
        activeUserEmail = nil
        activeUserDisplayName = nil
        activeUserMethods = []
        failedAttempts = [:]
        
        print("🔧 DEBUG: Tokens force-expired + server session cleared")
    }
    
    // MARK: - Server Actions
    
    public func resetFailedAttempts() {
        server.resetFailedAttempts()
        failedAttempts = [:]
        print("🔧 DEBUG: Failed attempts reset")
    }
    
    public func forceExpireChallenges() {
        server.forceExpireAllChallenges()
        print("🔧 DEBUG: All challenges force-expired")
    }
    
    public func logoutUser() {
        server.logout()
        activeUserEmail = nil
        activeUserDisplayName = nil
        activeUserMethods = []
        failedAttempts = [:]
        currentAuthToken = nil
        currentRefreshToken = nil
        print("🔧 DEBUG: User logged out from server")
    }
}
