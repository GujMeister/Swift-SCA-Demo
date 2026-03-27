//
//  RealSecureStorage.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 07.03.26.
//

/// In-memory implementation of `SecureStorage`.
/// Stands in for Keychain in demo flows.

import Foundation
import SCACore

public final class RealSecureStorage: SecureStorage {
    
    // MARK: - State
    
    private var authToken: String?
    private var refreshToken: String?
    private var deviceTrusted: Bool
    private var trustExpiryDate: Date?
    private let deviceId: String
    private let deviceName: String?
    private var tokenIssuedAt: Date?
    
    // MARK: - Init
    
    /// - Parameters:
    ///   - deviceTrusted: Pre-seed trust status (e.g. `true` to simulate a returning user).
    ///   - trustDurationDays: How long trust lasts from init. Defaults to 30 (PSD2 typical).
    ///   - deviceId: Stable identifier. Random UUID by default.
    ///   - deviceName: Display name for settings UI.
    public init(
        deviceTrusted: Bool = false,
        trustDurationDays: Int = 30,
        deviceId: String = UUID().uuidString,
        deviceName: String? = nil
    ) {
        self.deviceTrusted = deviceTrusted
        self.trustExpiryDate = deviceTrusted
            ? Calendar.current.date(byAdding: .day, value: trustDurationDays, to: Date())
            : nil
        self.deviceId = deviceId
        self.deviceName = deviceName
    }
    
    // MARK: - Token Validity
    
    public func isTokenValid(ttl: Int) async -> Bool {
        guard authToken != nil, let issued = tokenIssuedAt else { return false }
        return Date().timeIntervalSince(issued) < Double(ttl)
    }
    
    // MARK: - Authentication Tokens
    
    public func storeAuthenticationToken(_ token: String) async throws {
        authToken = token
        tokenIssuedAt = Date()
    }
    
    public func getAuthenticationToken() async -> String? {
        authToken
    }
    
    public func clearAuthenticationToken() async {
        authToken = nil
        tokenIssuedAt = nil
    }
    
    // MARK: - Refresh Tokens
    
    public func storeRefreshToken(_ token: String) async throws {
        refreshToken = token
    }
    
    public func getRefreshToken() async -> String? {
        refreshToken
    }
    
    public func clearRefreshToken() async {
        refreshToken = nil
    }
    
    // MARK: - Device Trust
    
    /// Checks both the flag and expiry — auto-clears if past date.
    public func isDeviceTrusted() async -> Bool {
        guard deviceTrusted, let expiry = trustExpiryDate else { return false }
        if expiry < Date() {
            deviceTrusted = false
            trustExpiryDate = nil
            return false
        }
        return true
    }
    
    public func markDeviceAsTrusted() async throws {
        deviceTrusted = true
        trustExpiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
    }
    
    public func clearDeviceTrust() async {
        deviceTrusted = false
        trustExpiryDate = nil
    }
    
    public func getDaysUntilTrustExpiry() async -> Int? {
        guard await isDeviceTrusted(), let expiry = trustExpiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiry).day
    }
    
    // MARK: - Device Identification
    
    public func getDeviceId() async -> String {
        deviceId
    }
    
    public func getDeviceName() async -> String? {
        deviceName
    }
}
