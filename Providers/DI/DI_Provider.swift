//
//  DI_Provider.swift
//  ProviderLayer
//
//  Created by Luka Gujejiani on 07.03.26.
//

import Core
import Swinject
import SCACore

// MARK: - Public

@MainActor
public extension DependencyContainer {
    static func registerProviderServices() {
        registerSCA()
        registerCrossLayerServices()
        registerSCAServer()
    }
}

// MARK: - Private

@MainActor
private extension DependencyContainer {
    static func registerSCA() {
        shared.register((any BiometricProvider).self) { _ in
            LocalAuthBiometricProvider()
        }
        
        shared.register((any SecureStorage).self, scope: .container) { _ in
            RealSecureStorage()
        }
    }
    
    static func registerSCAServer() {
        shared.register(MockSCAServer.self, scope: .container) { _ in
            MockSCAServer()
        }
        
        shared.register((any SCAProvider).self, scope: .container) { resolver in
            RealSCAProvider(server: resolver.resolve(MockSCAServer.self)!)
        }
    }
    
    static func registerCrossLayerServices() {
        shared.register(SCAService.self, scope: .container) { resolver in
            DefaultSCAService(
                provider: resolver.resolve((any SCAProvider).self)!,
                storage: resolver.resolve((any SecureStorage).self)!,
                biometrics: resolver.resolve((any BiometricProvider).self)!,
                ui: resolver.resolve((any UserInteraction).self)!
            )
        }
    }
}
