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
        content
            .sheet(isPresented: showOTPSheet) { // MARK: OTP
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
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
            .sheet(isPresented: showMethodPickerSheet) { // MARK: Method Picker View
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
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
            .sheet(isPresented: showTrustSheet) { // MARK: Trust Device Sheet
                TrustDeviceView(
                    onAccept: {
                        Task { await viewModel.process(.respondedToTrust(true)) }
                    },
                    onDecline: {
                        Task { await viewModel.process(.respondedToTrust(false)) }
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
            .sheet(isPresented: showInfoPageSheet) { // MARK: Info Sheet
                InfoView { profileToAutofill in
                    Task { await viewModel.process(.autofillLoginData(profileToAutofill)) }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .overlay(alignment: .top) { // MARK: Attempts Warning Banner
                if let remaining = viewModel.state.attemptsRemaining {
                    AttemptsWarningBanner(attemptsRemaining: remaining)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.state.attemptsRemaining)
    }
}

// MARK: - Content

private extension LoginView {
    var content: some View {
        VStack(spacing: 24) {
            header
            loginFieldsHeader
            loginFields
            loginButton
            Spacer()
        }
    }
}

// MARK: - Components

private extension LoginView {

    var header: some View {
        HStack(spacing: .zero) {
            Text("Login")
                .font(.largeTitle.bold())
            
            Spacer()
            
            Button {
                Task { await viewModel.process(.showInfoPage) }
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal, 24)
    }

    var loginFieldsHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.blue.gradient.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 32)
            
            VStack(spacing: 6) {
                Text("SCA Demo")
                    .font(.title.bold())
                
                Text("Strong Customer Authentication")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var loginFields: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(16)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }
            .padding(16)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
    }
    
    var loginButton: some View {
        VStack(spacing: 16) {
            Button {
                Task { await viewModel.process(.login) }
            } label: {
                Group {
                    if case .verifying = viewModel.coordinator.currentStep {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Text("Sign In")
                                .font(.body.weight(.semibold))
                            Image(systemName: "arrow.right")
                                .font(.callout.weight(.semibold))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            if let error = viewModel.state.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.errorMessage)
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
    
    var showInfoPageSheet: Binding<Bool> {
        Binding(
            get: { viewModel.state.isInfoPagePresent },
            set: { if !$0 { Task { await viewModel.process(.dismissInfoPage) } } }
        )
    }
}
