//
//  AuthenticationMethod.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 24.03.26.
//

import SCACore

public extension AuthenticationMethod {
    /// Icon name for UI (SF Symbols)
    var iconName: String {
        switch identifier {
        case "password": return "key.fill"
        case "pin": return "number.circle.fill"
        case "security_question": return "questionmark.circle.fill"
        case "pattern": return "square.grid.3x3.fill"
        case "sms_otp": return "message.fill"
        case "email_otp": return "envelope.fill"
        case "totp": return "clock.fill"
        case "push": return "bell.fill"
        case "security_key": return "personalhotspot"
        case "webauthn", "face_id": return "faceid"
        case "touch_id": return "touchid"
        case "voice": return "waveform"
        case "biometric": return "person.fill"
        default: return "lock.fill"
        }
    }
    
    /// Short description for user
    var description: String {
        switch identifier {
        case "password": return "Enter your password"
        case "pin": return "Enter your PIN code"
        case "security_question": return "Answer your security question"
        case "pattern": return "Draw your pattern"
        case "sms_otp": return "Enter code sent via SMS"
        case "email_otp": return "Enter code sent to email"
        case "totp": return "Enter code from authenticator app"
        case "push": return "Approve the notification"
        case "security_key": return "Insert your security key"
        case "webauthn", "face_id": return "Authenticate with Face ID"
        case "touch_id": return "Authenticate with Touch ID"
        case "voice": return "Speak your passphrase"
        case "biometric": return "Authenticate with biometric"
        default: return "Complete authentication"
        }
    }
}

