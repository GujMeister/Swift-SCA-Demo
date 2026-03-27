//
//  DependencyContainer.swift
//  Core
//
//  Created by Luka Gujejiani on 05.03.26.
//

import Swinject
import Foundation

// MARK: - DependencyContainer

public final class DependencyContainer: @unchecked Sendable {
    public static let shared = DependencyContainer()
    
    private var container: Container
    private let lock = NSRecursiveLock()
    
    private init() {
        self.container = Container()
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        guard let resolved = container.resolve(type) else {
            fatalError("No registration found for \(type) in DependencyContainer")
        }
        return resolved
    }
    
    public func register<T>(
        _ type: T.Type,
        scope: ObjectScope = .graph,
        factory: @escaping (Resolver) -> T
    ) {
        lock.lock()
        defer { lock.unlock() }
        container.register(type, factory: factory).inObjectScope(scope)
    }
    
    // MARK: Testing Support
    
#if DEBUG
    public static func swapForTesting(_ testContainer: Container) {
        shared.lock.lock()
        defer { shared.lock.unlock() }
        shared.container = testContainer
    }
    
    public static func resetToDefault() {
        shared.lock.lock()
        defer { shared.lock.unlock() }
        shared.container = Container()
    }
#endif
}

// MARK: - Inject

@propertyWrapper
public struct Inject<T> {
    public let wrappedValue: T
    
    public init() {
        self.wrappedValue = DependencyContainer.shared.resolve(T.self)
    }
}
