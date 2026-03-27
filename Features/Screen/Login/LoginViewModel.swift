//
//  LoginViewModel.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 05.03.26.
//

import ProviderLayer
import Combine
import Core
import Observation
import SCACore
import OSLog

extension LoginViewModel {
    struct Parameters { }
    
    struct Dependencies {
        let scaService: SCAService
        let coordinator: SCAFlowCoordinator
        
        static func resolve() -> Dependencies {
            let container = DependencyContainer.shared
            return Dependencies(
                scaService: container.resolve(SCAService.self),
                coordinator: container.resolve(SCAFlowCoordinator.self)
            )
        }
    }
    
    struct State {
        var email: String = ""
        var password: String = ""
        var otpCode: String = ""
        var errorMessage: String?
        var attemptsRemaining: Int?
    }
    
    enum Intent {
        case login
        case selectedMethod(AuthenticationMethod)
        case enteredOTP(String)
        case respondedToTrust(Bool)
        case cancelled
        case resetAfterSignOut
    }
}

@Observable
final class LoginViewModel: ViewModel {
    private(set) var state = State()
    
    /// Exposed so View can read `coordinator.currentStep` for UI state
    let coordinator: SCAFlowCoordinator
    
    @ObservationIgnored
    private let parameters: Parameters
    
    @ObservationIgnored
    private let dependencies: Dependencies
    
    private let logger = Logger(subsystem: "SCACore", category: "Login")
    
    // MARK: - Bindings
    
    var email: String {
        get { state.email }
        set { state.email = newValue }
    }
    
    var password: String {
        get { state.password }
        set { state.password = newValue }
    }
    
    // MARK: - Init
    
    init(parameters: Parameters, dependencies: Dependencies) {
        self.parameters = parameters
        self.dependencies = dependencies
        self.coordinator = dependencies.coordinator
    }
    
    func onViewReady() { }
    
    func process(_ intent: Intent) async {
        switch intent {
        case .login:
            await login()
        case .selectedMethod(let method):
            coordinator.userSelectedMethod(method)
        case .enteredOTP(let code):
            coordinator.userEnteredCredential(code)
        case .respondedToTrust(let accepted):
            coordinator.userRespondedToTrust(accepted)
        case .cancelled:
            coordinator.userCancelled()
        case .resetAfterSignOut:
            resetAfterSignOut()
        }
    }
}

// MARK: - Private

private extension LoginViewModel {
    
    func login() async {
        guard !state.email.isEmpty, !state.password.isEmpty else {
            state.errorMessage = "Enter email and password"
            return
        }
        
        state.errorMessage = nil
        state.attemptsRemaining = nil
        
        do {
            let challenge = try await dependencies.scaService.startChallenge(
                for: .login,
                context: ChallengeContext(email: state.email)
            )
            
            coordinator.prefillCredential(state.password, for: .knowledge)
            
            _ = try await dependencies.scaService.authenticate(challenge: challenge)
            
            let sessionMonitor = DependencyContainer.shared.resolve(SessionMonitor.self)
            sessionMonitor.markSessionActive()
            
        } catch let error as SCAError {
            switch error {
            case .userCancelled:
                state.errorMessage = "Authentication cancelled"
                
            case .challengeExpired:
                state.errorMessage = "Challenge expired, try again"
                
            case .verificationFailed(let remaining):
                state.attemptsRemaining = remaining
                state.errorMessage = remaining != nil
                ? "Wrong password or code — \(remaining!) attempt(s) left"
                : "Wrong password or code"
                
            default:
                state.errorMessage = "Authentication failed"
            }
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
    
    private func resetAfterSignOut() {
        state.password = ""
        state.errorMessage = nil
        state.attemptsRemaining = nil
    }
}
