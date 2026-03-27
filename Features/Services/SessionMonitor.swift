//
//  SessionMonitor.swift
//  Application
//
//  Created by Luka Gujejiani on 27.03.26.
//

import Observation
import SCACore
import ProviderLayer

@MainActor
@Observable
public final class SessionMonitor {
    
    public var isSessionValid: Bool = false
    
    @ObservationIgnored
    private let storage: SecureStorage
    
    @ObservationIgnored
    private let server: MockSCAServer
    
    @ObservationIgnored
    private var pollingTask: Task<Void, Never>?
    
    public init(storage: SecureStorage, server: MockSCAServer) {
        self.storage = storage
        self.server = server
    }
    
    public func markSessionActive() {
        isSessionValid = true
        startMonitoring()
    }
    
    public func endSession() {
        stopMonitoring()
        isSessionValid = false
    }
    
    private func startMonitoring() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { return }
                await checkValidity()
            }
        }
    }
    
    private func stopMonitoring() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func checkValidity() async {
        let valid = await storage.isTokenValid(ttl: server.config.tokenExpiresIn)
        
        guard valid else {
            if isSessionValid {
                print("SESSION: Token expired — ending session")
                await storage.clearAuthenticationToken()
                await storage.clearRefreshToken()
                isSessionValid = false
            }
            return
        }
    }
}
