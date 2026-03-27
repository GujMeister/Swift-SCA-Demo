//
//  DI_Application.swift
//  Application
//
//  Created by Luka Gujejiani on 27.03.26.
//

import Core
import ProviderLayer
import FeatureLayer
import SCACore

@MainActor
extension DependencyContainer {
    static func registerServices() {
        registerProviderServices()
        registerFeatureServices()
        registerDebug()
        
        func registerDebug() {
            let server = shared.resolve(MockSCAServer.self)
            let storage = shared.resolve(SecureStorage.self)
            shared.register(DebugController.self) { _ in
                DebugController(server: server, storage: storage)
            }
        }
    }
}
