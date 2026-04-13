//
//  InfoViewModel.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 13/04/2026.
//

import ProviderLayer
import Core
import Observation
import SCACore

extension InfoViewModel {
    struct Parameters {
        let onSelect: (MockUserProfile) -> Void
        let onColdStart: (MockUserProfile) -> Void
    }
    
    struct Dependencies {
        let scaService: SCAService
        let biometrics: BiometricProvider
        
        static func resolve() -> Dependencies {
            let container = DependencyContainer.shared
            return Dependencies(
                scaService: container.resolve(SCAService.self),
                biometrics: container.resolve(BiometricProvider.self)
            )
        }
    }
    
    struct State {
        var isDeviceTrusted: Bool = false
        var isBiometricsAvailable: Bool = false
    }
    
    enum Intent {
        case refreshPreconditions
        case selectedProfile(MockUserProfile)
        case triggeredColdStart(MockUserProfile)
    }
}

@MainActor
@Observable
final class InfoViewModel: ViewModel {
    private(set) var state = State()
    
    @ObservationIgnored
    private let parameters: Parameters
    
    @ObservationIgnored
    private let dependencies: Dependencies
    
    init(parameters: Parameters, dependencies: Dependencies) {
        self.parameters = parameters
        self.dependencies = dependencies
    }
    
    func onViewReady() { }
    
    var canColdStart: Bool {
        state.isDeviceTrusted && state.isBiometricsAvailable
    }
    
    func process(_ intent: Intent) async {
        switch intent {
        case .refreshPreconditions:
            await refreshPreconditions()
        case .selectedProfile(let profile):
            parameters.onSelect(profile)
        case .triggeredColdStart(let profile):
            parameters.onColdStart(profile)
        }
    }
}

private extension InfoViewModel {
    func refreshPreconditions() async {
        state.isDeviceTrusted = await dependencies.scaService.isDeviceTrusted
        state.isBiometricsAvailable = await dependencies.biometrics.isAvailable
    }
}
