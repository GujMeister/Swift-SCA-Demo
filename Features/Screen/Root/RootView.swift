//
//  RootView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 27.03.26.
//

import SwiftUI
import Core

public struct RootView: View {
    
    private let debugController = DependencyContainer.shared.resolve(DebugController.self)
    
    @Bindable
    private var sessionMonitor = DependencyContainer.shared.resolve(SessionMonitor.self)
    
    public init() {}
    
    public var body: some View {
        ZStack {
            NavigationStack {
                LoginView()
                    .navigationDestination(isPresented: $sessionMonitor.isSessionValid) {
                        HomeView()
                    }
            }
            
            DebugOverlay(controller: debugController)
        }
    }
}
