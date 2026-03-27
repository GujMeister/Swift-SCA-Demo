//
//  LoginView.swift
//  FeatureLayer
//
//  Created by Luka Gujejiani on 05.03.26.
//

import SwiftUI
import SCACore
import Core

struct LoginView: View {
    
    @State
    private var viewModel = LoginViewModel(
        parameters: .init(),
        dependencies: .resolve()
    )
    
    init() { }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Header
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.top, 40)
            
            Text("SCA Demo")
                .font(.title.bold())
            
            // MARK: - Login Fields
            
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            // MARK: - Error
            
            if let error = viewModel.state.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.callout)
            }
            
            // MARK: - Login Button
            
            Button {
                Task { await viewModel.process(.login) }
            } label: {
                Group {
                    if case .verifying = viewModel.coordinator.currentStep {
                        ProgressView()
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Login")
        
        // MARK: - OTP Sheet
        
        .sheet(isPresented: showOTPSheet) {
            OTPEntryView(
                method: otpMethod,
                onSubmit: { code in
                    Task { await viewModel.process(.enteredOTP(code)) }
                },
                onCancel: {
                    Task { await viewModel.process(.cancelled) }
                },
                onResend: {
                    viewModel.coordinator.resendOTP()
                },
                cooldown: viewModel.coordinator.resendCooldown
            )
        }
        
        // MARK: - MethodPickerView
        
        .sheet(isPresented: showMethodPickerSheet) {
            MethodPickerView(
                methods: pickerMethods,
                reason: pickerReason,
                onSelect: { method in
                    Task { await viewModel.process(.selectedMethod(method)) }
                },
                onCancel: {
                    Task { await viewModel.process(.cancelled) }
                }
            )
        }
        
        // MARK: - Trust Device Sheet
        
        .sheet(isPresented: showTrustSheet) {
            TrustDeviceView(
                onAccept: {
                    Task { await viewModel.process(.respondedToTrust(true)) }
                },
                onDecline: {
                    Task { await viewModel.process(.respondedToTrust(false)) }
                }
            )
        }
        
        // MARK: - Attempts Warning Banner
        
        .overlay(alignment: .top) {
            if let remaining = viewModel.state.attemptsRemaining {
                AttemptsWarningBanner(attemptsRemaining: remaining)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state.attemptsRemaining)
    }
}

// MARK: - Computed Helpers

private extension LoginView {
    var showMethodPickerSheet: Binding<Bool> {
        Binding(
            get: {
                if case .selectMethod = viewModel.coordinator.currentStep { return true }
                return false
            },
            set: { if !$0 { Task { await viewModel.process(.cancelled) } } }
        )
    }
    
    var pickerMethods: [AuthenticationMethod] {
        if case .selectMethod(let methods, _) = viewModel.coordinator.currentStep {
            return methods
        }
        return []
    }
    
    var pickerReason: ChallengeReason {
        if case .selectMethod(_, let reason) = viewModel.coordinator.currentStep {
            return reason
        }
        return .login
    }
    
    var isLoading: Bool {
        if case .verifying = viewModel.coordinator.currentStep { return true }
        return false
    }
    
    var showOTPSheet: Binding<Bool> {
        Binding(
            get: {
                if case .enterOTP = viewModel.coordinator.currentStep { return true }
                return false
            },
            set: { if !$0 { Task { await viewModel.process(.cancelled) } } }
        )
    }
    
    var showTrustSheet: Binding<Bool> {
        Binding(
            get: {
                if case .promptTrust = viewModel.coordinator.currentStep { return true }
                return false
            },
            set: { if !$0 { Task { await viewModel.process(.respondedToTrust(false)) } } }
        )
    }
    
    var otpMethod: AuthenticationMethod? {
        if case .enterOTP(let method) = viewModel.coordinator.currentStep {
            return method
        }
        return nil
    }
}
