//
//  ViewModel.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 05.03.26.
//

// MARK: - Core Protocol

@MainActor
protocol ViewModel {
    /// What the VM needs to be created
    associatedtype Parameters

    /// The consolidated view state
    associatedtype State

    /// User-driven actions the VM can handle
    associatedtype Intent
    
    /// Registering any dependencies
    associatedtype Dependencies

    /// Current view state
    var state: State { get }

    /// Single entry point for all view actions
    func perform(_ intent: Intent)
    
    /// Override this — your actual intent logic
    func process(_ intent: Intent) async

    /// Lifecycle hook — called once when the view appears
    func onViewReady()

    init(parameters: Parameters, dependencies: Dependencies)
}

// MARK: - Defaults

extension ViewModel {
    func perform(_ intent: Intent) {
        Task { await process(intent) }
    }

    func onViewReady() {}
}

// MARK: - Initizer

/// No Parameters
extension ViewModel where Parameters == Void {
    init(dependencies: Dependencies) {
        self.init(parameters: (), dependencies: dependencies)
    }
}

/// No Dependencies
extension ViewModel where Dependencies == Void {
    init(parameters: Parameters) {
        self.init(parameters: parameters, dependencies: ())
    }
}

/// No Parameters, No Dependencies
extension ViewModel where Parameters == Void, Dependencies == Void {
    init() {
        self.init(parameters: (), dependencies: ())
    }
}
