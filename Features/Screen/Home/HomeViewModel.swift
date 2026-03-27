//
//  HomeViewModel.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 27.03.26.
//

import Observation
import SCACore
import Core

extension HomeViewModel {
    struct Parameters { }
    
    struct Dependencies {
        let scaService: SCAService
        let storage: SecureStorage
        
        static func resolve() -> Dependencies {
            let container = DependencyContainer.shared
            return Dependencies(
                scaService: container.resolve(SCAService.self),
                storage: container.resolve(SecureStorage.self)
            )
        }
    }
    
    struct State {
        var usedMethods: [String] = []
        var tokenPreview: String?
    }
    
    enum Intent {
        case signOut
    }
}

@Observable
final class HomeViewModel: ViewModel {
    private(set) var state = State()
    
    @ObservationIgnored
    private let parameters: Parameters
    
    @ObservationIgnored
    private let dependencies: Dependencies
    
    init(
        parameters: Parameters,
        dependencies: Dependencies
    ) {
        self.parameters = parameters
        self.dependencies = dependencies
    }
    
    func onViewReady() {
        Task {
            let token = await dependencies.storage.getAuthenticationToken()
            state.tokenPreview = token.map { "..." + String($0.suffix(12)) }
        }
    }
    
    func process(_ intent: Intent) async {
        switch intent {
        case .signOut:
            await signOut()
        }
    }
}

// MARK: - Private

private extension HomeViewModel {
    func signOut() async {
        await dependencies.scaService.signOut()
        let sessionMonitor = DependencyContainer.shared.resolve(SessionMonitor.self)
        sessionMonitor.endSession()
    }
}
