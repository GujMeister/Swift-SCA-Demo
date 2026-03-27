//
//  DebugOverlay.swift
//  Application
//
//  Created by Luka Gujejiani on 26.03.26.
//

import SwiftUI

public struct DebugOverlay: View {
    
    let controller: DebugController
    
    @State
    private var showPanel = false
    
    public init(controller: DebugController) {
        self.controller = controller
    }
    
    public var body: some View {
        DebugFloatingButton(showPanel: $showPanel)
            .sheet(isPresented: $showPanel) {
                DebugPanelView(controller: controller)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
    }
}
