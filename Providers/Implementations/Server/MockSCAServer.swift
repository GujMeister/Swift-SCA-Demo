//
//  MockSCAServer.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 08.03.26.
//

import Foundation
import SCACore

@MainActor
public final class MockSCAServer {
    
    public var config: Configuration
    
    private(set) public var activeUser: MockUserProfile?
    private var challengeReasons: [String: ChallengeReason] = [:]
    private var submittedProofs: [String: [AuthenticationProof]] = [:]
    private var failedAttempts: [String: Int] = [:]
    private var challengeExpiry: [String: Date] = [:]
    
    public init(config: Configuration = Configuration()) {
        self.config = config
    }
    
    // MARK: - User Management
    
    public func loginUser(email: String) throws -> MockUserProfile {
        guard let user = MockUserProfile.find(email: email) else {
            print("⚠️ MOCK SERVER: Account '\(email)' is not mocked. Available: \(MockUserProfile.allProfiles.map(\.email).joined(separator: ", "))")
            throw MockServerError.accountNotFound(email)
        }
        
        print("MOCK SERVER: User '\(user.displayName)' (\(user.email)) logged in")
        print("MOCK SERVER: Enrolled methods → \(user.allMethods.map(\.identifier))")
        activeUser = user
        return user
    }
    
    public func logout() {
        print("MOCK SERVER: User logged out")
        activeUser = nil
        challengeReasons.removeAll()
        submittedProofs.removeAll()
        failedAttempts.removeAll()
        challengeExpiry.removeAll()
    }
    
    // MARK: - Challenge
    
    public func createChallenge(
        for reason: ChallengeReason,
        context: ChallengeContext?
    ) throws -> SCAChallenge {
        // Look up user from email in context
        if let email = context?.email {
            let _ = try loginUser(email: email)
        }
        
        guard let user = activeUser else {
            print("⚠️ MOCK SERVER: No active user — provide email in ChallengeContext")
            throw MockServerError.accountNotFound("no email provided")
        }
        
        let challengeId = UUID().uuidString
        challengeReasons[challengeId] = reason
        
        let expiresAt = Calendar.current.date(
            byAdding: .minute,
            value: config.challengeExpirationMinutes,
            to: Date()
        )!
        challengeExpiry[challengeId] = expiresAt
        
        print("MOCK SERVER: Challenge created for \(user.displayName) — methods: \(user.allMethods.map(\.identifier)), reason: \(reason.rawValue)")
        
        return SCAChallenge(
            challengeId: challengeId,
            availableMethods: user.allMethods,
            minimumFactorsNeeded: config.minimumFactors,
            reason: reason,
            expiresAt: expiresAt
        )
    }
    
    // MARK: - Verification
    
    public func verifyProof(_ proof: AuthenticationProof) throws -> VerificationStepResult {
        if let expiry = challengeExpiry[proof.challengeId], Date() > expiry {
            print("⚠️ MOCK SERVER: Challenge expired")
            throw SCAError.challengeExpired
        }
        
        guard let user = activeUser else {
            throw MockServerError.accountNotFound("no active user")
        }
        
        let maxAttempts = 3
        
        let attemptKey = user.email
        let currentFailures = failedAttempts[attemptKey, default: 0]
        
        guard currentFailures < maxAttempts else {
            print("⚠️ MOCK SERVER: Account locked — too many failures")
            throw SCAError.verificationFailed(attemptsRemaining: 0)
        }
        
        // Validate knowledge factor (password/PIN)
        if proof.method.category == .knowledge {
            guard proof.credential == user.password else {
                failedAttempts[attemptKey, default: 0] += 1
                let remaining = maxAttempts - failedAttempts[attemptKey]!
                print("⚠️ MOCK SERVER: Wrong password for \(user.email) — \(remaining) attempt(s) left")
                throw SCAError.verificationFailed(attemptsRemaining: remaining)
            }
        }
        
        // Validate possession factor — accept "123456"
        if proof.method.category == .possession {
            guard proof.credential == "123456" else {
                failedAttempts[attemptKey, default: 0] += 1
                let remaining = maxAttempts - failedAttempts[attemptKey]!
                print("⚠️ MOCK SERVER: Wrong OTP code — \(remaining) attempt(s) left")
                throw SCAError.verificationFailed(attemptsRemaining: remaining)
            }
        }
        
        // Validate inherence factor
        if proof.method.category == .inherence {
            guard proof.credential == "biometric_success" else {
                print("⚠️ MOCK SERVER: Biometric verification failed")
                throw SCAError.verificationFailed(attemptsRemaining: nil)
            }
        }
        
        submittedProofs[proof.challengeId, default: []].append(proof)
        let allProofs = submittedProofs[proof.challengeId]!
        let reason = challengeReasons[proof.challengeId] ?? .login
        
        let satisfiedCategories = Set(allProofs.map { $0.method.category })
        
        print("MOCK SERVER: Proof verified ✅ — method: \(proof.method.identifier), satisfied categories: \(satisfiedCategories.map(\.rawValue))")
        
        guard satisfiedCategories.count >= config.minimumFactors else {
            print("MOCK SERVER: Partial — need \(config.minimumFactors - satisfiedCategories.count) more factor(s)")
            return .partial(satisfiedCategories: satisfiedCategories)
        }
        
        print("MOCK SERVER: All factors satisfied — issuing token 🎟️")
        
        let result = AuthenticationResult(
            authenticationToken: "mock_token_\(UUID().uuidString)",
            expiresIn: config.tokenExpiresIn,
            refreshToken: config.issuesRefreshTokens ? "mock_refresh_\(UUID().uuidString)" : nil,
            scope: reason,
            usedMethods: allProofs.map { $0.method }
        )
        
        return .complete(result)
    }
    
    // MARK: - OTP
    
    public func sendOTP(method: AuthenticationMethod, challengeId: String) throws {
        guard activeUser != nil else {
            throw MockServerError.accountNotFound("no active user")
        }
        print("MOCK SERVER: OTP sent via \(method.identifier) — use code '123456'")
    }
    
    // MARK: - Token Refresh
    
    public func refreshToken(_ refreshToken: String) throws -> AuthenticationResult {
        guard refreshToken.hasPrefix("mock_refresh_") else {
            print("⚠️ MOCK SERVER: Invalid refresh token")
            throw SCAError.refreshTokenExpired
        }
        
        print("MOCK SERVER: Token refreshed ✅")
        
        return AuthenticationResult(
            authenticationToken: "mock_token_\(UUID().uuidString)",
            expiresIn: config.tokenExpiresIn,
            refreshToken: config.issuesRefreshTokens ? "mock_refresh_\(UUID().uuidString)" : nil,
            scope: .login,
            usedMethods: []
        )
    }
}

// MARK: - Debug methods

public extension MockSCAServer {
    func resetFailedAttempts() {
        failedAttempts.removeAll()
        print("🔧 DEBUG: Failed attempts reset")
    }
    
    func forceExpireAllChallenges() {
        let past = Date.distantPast
        for key in challengeExpiry.keys {
            challengeExpiry[key] = past
        }
        print("🔧 DEBUG: All challenges force-expired")
    }
    
    var currentFailedAttempts: [String: Int] {
        failedAttempts
    }
}

// MARK: - Configuration

public extension MockSCAServer {
    struct Configuration {
        public var networkDelay: TimeInterval
        public var challengeExpirationMinutes: Int
        public var issuesRefreshTokens: Bool
        public var tokenExpiresIn: Int
        public var minimumFactors: Int
        
        public init(
            networkDelay: TimeInterval = 1.0,
            challengeExpirationMinutes: Int = 5,
            issuesRefreshTokens: Bool = true,
            tokenExpiresIn: Int = 300,
            minimumFactors: Int = 2
        ) {
            self.networkDelay = networkDelay
            self.challengeExpirationMinutes = challengeExpirationMinutes
            self.issuesRefreshTokens = issuesRefreshTokens
            self.tokenExpiresIn = tokenExpiresIn
            self.minimumFactors = minimumFactors
        }
    }
}

public enum MockServerError: Error, LocalizedError {
    case accountNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .accountNotFound(let email):
            return "Account '\(email)' is not mocked"
        }
    }
}
