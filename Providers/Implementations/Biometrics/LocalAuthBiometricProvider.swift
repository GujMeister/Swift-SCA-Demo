//
//  LocalAuthBiometricProvider.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 07.03.26.
//

import LocalAuthentication
import SCACore

public final class LocalAuthBiometricProvider: BiometricProvider {
    
    public init() {}
    
    public var isAvailable: Bool {
        get async {
            let context = LAContext()
            return context.canEvaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                error: nil
            )
        }
    }
    
    public var biometricType: BiometricType? {
        get async {
            let context = LAContext()
            guard context.canEvaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                error: nil
            ) else { return nil }
            
            switch context.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            default: return nil
            }
        }
    }
    
    public func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        
        // Don't allow device passcode as fallback — we want biometric only
        context.localizedFallbackTitle = " Don't allow device passcode as fallback — we want biometric only"
        
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                throw BiometricError.userCancelled
            case .authenticationFailed:
                throw BiometricError.authenticationFailed
            case .biometryLockout:
                throw BiometricError.biometricsLocked
            case .biometryNotEnrolled:
                throw BiometricError.notEnrolled
            case .biometryNotAvailable:
                throw BiometricError.notAvailable
            default:
                throw BiometricError.authenticationFailed
            }
        }
    }
}
