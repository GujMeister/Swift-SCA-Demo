//
//  HomeView.swift
//  Application
//
//  Created by Luka Gujejiani on 27.03.26.
//

import SwiftUI

struct HomeView: View {
    
    @State
    private var viewModel: HomeViewModel
    
    init() {
        _viewModel = State(initialValue: HomeViewModel(
            parameters: .init(),
            dependencies: .resolve()
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Authenticated!")
                .font(.title.bold())
            
            Text("You're securely signed in")
                .foregroundStyle(.secondary)
            
            if let token = viewModel.state.tokenPreview {
                Text("Token: \(token)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .navigationTitle("Home")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Sign Out") {
                    Task { await viewModel.process(.signOut) }
                }
                .foregroundStyle(.red)
            }
        }
        .onAppear { viewModel.onViewReady() }
    }
}
