//
//  DI_Feature.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 05.03.26.
//

import Core
import Swinject
import SCACore
import ProviderLayer

// MARK: - Public

@MainActor
public extension DependencyContainer {
    static func registerFeatureServices() {
        registerSCAFlowCoordinator()
        registerSessionMonitor()
    }
}

// MARK: - Private

@MainActor
private extension DependencyContainer {
    static func registerSCAFlowCoordinator() {
        shared.register(SCAFlowCoordinator.self, scope: .container) { _ in
            SCAFlowCoordinator()
        }
        
        shared.register((any UserInteraction).self, scope: .container) { resolver in
            resolver.resolve(SCAFlowCoordinator.self)!
        }
    }
    
    static func registerSessionMonitor() {
        shared.register(SessionMonitor.self, scope: .container) { resolver in
            SessionMonitor(
                storage: resolver.resolve((any SecureStorage).self)!,
                server: resolver.resolve(MockSCAServer.self)!
            )
        }
    }
}
