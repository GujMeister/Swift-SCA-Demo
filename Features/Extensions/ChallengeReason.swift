//
//  ChallengeReason.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SCACore

public extension ChallengeReason {
    /// User-facing title
    var title: String {
        switch self {
        case .login: return "Sign In"
        case .payment: return "Confirm Payment"
        case .settingsChange: return "Confirm Settings"
        case .sessionExpired: return "Session Expired"
        case .riskAssessment: return "Security Check"
        }
    }
    
    /// Message shown to user
    var message: String {
        switch self {
        case .login:
            return "Authenticate to continue"
        case .payment:
            return "Confirm this payment"
        case .settingsChange:
            return "Confirm changes to your settings"
        case .sessionExpired:
            return "Your session has expired. Please authenticate again."
        case .riskAssessment:
            return "Unusual activity detected. Please verify your identity."
        }
    }
    
    /// Icon for UI
    var iconName: String {
        switch self {
        case .login: return "person.circle.fill"
        case .payment: return "creditcard.fill"
        case .settingsChange: return "gearshape.fill"
        case .sessionExpired: return "clock.arrow.circlepath"
        case .riskAssessment: return "shield.fill"
        }
    }
}

