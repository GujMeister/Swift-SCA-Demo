//
//  Application.swift
//  Application
//
//  Created by Luka Gujejiani on 05.03.26.
//

import SwiftUI
import ProviderLayer
import FeatureLayer
import Core
import SCACore

@main
struct Application: App {
    
    init() {
        DependencyContainer.registerServices()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
