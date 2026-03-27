//
//  MockUserProfile.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 08.03.26.
//

import Foundation
import SCACore

public struct MockUserProfile: Sendable {
    public let email: String
    public let password: String
    public let displayName: String
    public let knowledgeMethods: [AuthenticationMethod]
    public let possessionMethods: [AuthenticationMethod]
    public let inherenceMethods: [AuthenticationMethod]
    
    public var allMethods: [AuthenticationMethod] {
        knowledgeMethods + possessionMethods + inherenceMethods
    }
}

// MARK: - Hardcoded Accounts

public extension MockUserProfile {
    
    /// Tech-savvy user: all methods available
    static let luka = MockUserProfile(
        email: "luka@mail.ge",
        password: "123",
        displayName: "Luka",
        knowledgeMethods: [.password],
        possessionMethods: [.smsOTP, .emailOTP],
        inherenceMethods: [.faceID]
    )
    
    /// Basic user: no biometrics enrolled, only password + SMS
    static let guest = MockUserProfile(
        email: "guest@mail.ge",
        password: "123",
        displayName: "Guest",
        knowledgeMethods: [.password],
        possessionMethods: [.smsOTP],
        inherenceMethods: []
    )
    
    /// Security-conscious user: everything enrolled including PIN
    static let admin = MockUserProfile(
        email: "admin@mail.ge",
        password: "123",
        displayName: "Admin",
        knowledgeMethods: [.password, .pin],
        possessionMethods: [.smsOTP, .emailOTP, .totp],
        inherenceMethods: [.faceID]
    )
    
    /// Minimal user: only password + email OTP
    static let minimal = MockUserProfile(
        email: "min@mail.ge",
        password: "123",
        displayName: "Minimal User",
        knowledgeMethods: [.password],
        possessionMethods: [.emailOTP],
        inherenceMethods: []
    )
    
    /// All available accounts
    static let allProfiles: [MockUserProfile] = [.luka, .guest, .admin, .minimal]
    
    /// Look up by email (case-insensitive)
    static func find(email: String) -> MockUserProfile? {
        allProfiles.first { $0.email.lowercased() == email.lowercased() }
    }
}
