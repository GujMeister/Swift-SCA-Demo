//
//  SCAFlowCoordinator.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 07.03.26.
//

import Observation
import SCACore
import Foundation

@MainActor
@Observable
public final class SCAFlowCoordinator {
    
    // MARK: - Observable State
    
    public var currentStep: SCAFlowStep = .idle
    public var resendCooldown: Int = 0
    
    // MARK: - Continuations
    
    @ObservationIgnored
    private var methodContinuation: CheckedContinuation<AuthenticationMethod, Error>?
    
    @ObservationIgnored
    private var credentialContinuation: CheckedContinuation<String, Error>?
    
    @ObservationIgnored
    private var trustContinuation: CheckedContinuation<Bool, Never>?
    
    @ObservationIgnored
    private var prefilled: [PSD2Category: String] = [:]
    
    @ObservationIgnored
    private var resendHandler: OTPResendHandler?
    
    @ObservationIgnored
    private var cooldownTask: Task<Void, Never>?
    
    public init() {}
    
    // MARK: - Resend OTP
    
    public func resendOTP() {
        guard resendCooldown == 0, let handler = resendHandler else { return }
        
        Task {
            do {
                try await handler()
                print("COORDINATOR: OTP resent ✅")
                startCooldown()
            } catch {
                print("COORDINATOR: OTP resend failed — \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - User Actions (View calls these)
    
    public func userSelectedMethod(_ method: AuthenticationMethod) {
        currentStep = .verifying
        methodContinuation?.resume(returning: method)
        methodContinuation = nil
    }
    
    public func userEnteredCredential(_ credential: String) {
        currentStep = .verifying
        cleanUpOTPState()
        credentialContinuation?.resume(returning: credential)
        credentialContinuation = nil
    }
    
    public func userRespondedToTrust(_ accepted: Bool) {
        currentStep = .idle
        trustContinuation?.resume(returning: accepted)
        trustContinuation = nil
    }
    
    public func userCancelled() {
        currentStep = .idle
        cleanUpOTPState()
        methodContinuation?.resume(throwing: UserInteractionError.cancelled)
        methodContinuation = nil
        credentialContinuation?.resume(throwing: UserInteractionError.cancelled)
        credentialContinuation = nil
        trustContinuation?.resume(returning: false)
        trustContinuation = nil
    }
    
    // MARK: - Private
    
    public func prefillCredential(_ credential: String, for category: PSD2Category) {
        prefilled[category] = credential
    }
    
    private func startCooldown() {
        resendCooldown = 30
        cooldownTask?.cancel()
        cooldownTask = Task {
            while resendCooldown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                resendCooldown -= 1
            }
        }
    }
    
    private func cleanUpOTPState() {
        resendHandler = nil
        cooldownTask?.cancel()
        cooldownTask = nil
        resendCooldown = 0
    }
}

// MARK: - UserInteraction Conformance

extension SCAFlowCoordinator: UserInteraction {
    public func hasPrefilledCredential(for category: PSD2Category) -> Bool {
        prefilled[category] != nil
    }
    
    public func selectAuthenticationMethod(
        from methods: [AuthenticationMethod],
        reason: ChallengeReason
    ) async throws -> AuthenticationMethod {
        for method in methods {
            if prefilled[method.category] != nil {
                print("COORDINATOR: Prefill found for \(method.category) — auto-picking \(method.identifier)")
                return method
            }
        }
        
        print("COORDINATOR: No prefill — suspending for user selection, methods: \(methods.map(\.identifier))")
        
        methodContinuation?.resume(throwing: UserInteractionError.cancelled)
        methodContinuation = nil
        
        return try await withCheckedThrowingContinuation { continuation in
            self.methodContinuation = continuation
            self.currentStep = .selectMethod(methods, reason)
        }
    }
    
    public func requestKnowledgeFactor(method: AuthenticationMethod) async throws -> String {
        if let credential = prefilled[method.category] {
            prefilled.removeValue(forKey: method.category)
            return credential
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.credentialContinuation = continuation
            self.currentStep = .enterKnowledge(method)
        }
    }
    
    public func requestPossessionFactor(
        method: AuthenticationMethod,
        resend: OTPResendHandler
    ) async throws -> String {
        self.resendHandler = resend
        startCooldown()
        
        return try await withCheckedThrowingContinuation { continuation in
            self.credentialContinuation = continuation
            self.currentStep = .enterOTP(method)
        }
    }
    
    public func promptToTrustDevice() async -> Bool {
        await withCheckedContinuation { continuation in
            self.trustContinuation = continuation
            self.currentStep = .promptTrust
        }
    }
    
    public func showError(_ error: Error) async {
        currentStep = .error(error.localizedDescription)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        currentStep = .idle
    }
}
