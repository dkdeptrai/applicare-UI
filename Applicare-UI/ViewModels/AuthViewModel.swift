//
//  AuthViewModel.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUser: User? = nil
    @Published var needsEmailVerification: Bool = false
    @Published var emailForVerification: String = ""
    
    private let authService: AuthNetworkServiceProtocol
    private let userService: UserNetworkServiceProtocol
    
    init(authService: AuthNetworkServiceProtocol = AuthNetworkService.shared,
         userService: UserNetworkServiceProtocol = UserNetworkService.shared) {
        self.authService = authService
        self.userService = userService
        
        // Check if user is already logged in
        isAuthenticated = authService.isUserLoggedIn()
        
        // If authenticated, fetch user details
        if isAuthenticated {
            fetchUserDetails()
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        needsEmailVerification = false
        
        let loginRequest = LoginRequestDTO(email: email, password: password)
        
        authService.login(loginRequest: loginRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.isAuthenticated = true
                    self?.fetchUserDetails()
                case .failure(let error):
                    switch error {
                    case .unauthorized:
                        self?.errorMessage = "Invalid email or password"
                    case .customError(let message):
                        if message.contains("email not verified") {
                            self?.needsEmailVerification = true
                            self?.emailForVerification = email
                            self?.errorMessage = "Please verify your email address before logging in"
                        } else {
                            self?.errorMessage = message
                        }
                    case .decodingFailed:
                        self?.errorMessage = "Could not process server response"
                    default:
                        self?.errorMessage = "An unexpected error occurred"
                    }
                }
            }
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        isLoading = true
        errorMessage = nil
        
        let registerRequest = RegisterRequestDTO(email: email, password: password, passwordConfirmation: confirmPassword)
        
        authService.register(registerRequest: registerRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    // After successful registration, user needs to verify email
                    self?.needsEmailVerification = true
                    self?.emailForVerification = email
                    self?.errorMessage = "Registration successful! Please check your email to verify your account."
                case .failure(let error):
                    switch error {
                    case .validationError(let message):
                        self?.errorMessage = "Validation failed: \(message)"
                    case .decodingFailed:
                        self?.errorMessage = "Could not process server response"
                    default:
                        self?.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func logout() {
        isLoading = true
        errorMessage = nil
        
        authService.logout { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                case .failure:
                    // Even if server logout fails, we'll still log out locally
                    self?.authService.clearAuthData()
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    self?.errorMessage = "Logout failed, but you've been logged out locally"
                }
            }
        }
    }
    
    func fetchUserDetails() {
        isLoading = true
        
        userService.getCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userDTO):
                    self?.currentUser = User(from: userDTO)
                    
                    // Check if email is verified
                    if let user = self?.currentUser, !user.isEmailVerified {
                        self?.needsEmailVerification = true
                        self?.emailForVerification = user.emailAddress
                    }
                case .failure:
                    // If we can't fetch user details, log out
                    self?.authService.clearAuthData()
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func verifyEmail(token: String) {
        isLoading = true
        errorMessage = nil
        
        let verifyRequest = VerifyEmailRequestDTO(token: token)
        
        authService.verifyEmail(verifyRequest: verifyRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.needsEmailVerification = false
                    self?.errorMessage = "Email verified successfully! You can now log in."
                case .failure(let error):
                    switch error {
                    case .validationError(let message):
                        self?.errorMessage = "Verification link has expired: \(message)"
                    case .invalidResponse:
                        self?.errorMessage = "Invalid verification token. Please check your email or request a new link."
                    default:
                        self?.errorMessage = "An error occurred during verification. Please try again."
                    }
                }
            }
        }
    }
    
    func resendVerificationEmail() {
        guard !emailForVerification.isEmpty else {
            errorMessage = "No email address available for verification"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let resendRequest = ResendVerificationRequestDTO(email: emailForVerification)
        
        authService.resendVerification(resendRequest: resendRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.errorMessage = "If your email is registered, a verification link has been sent. Please check your inbox."
                case .failure:
                    self?.errorMessage = "An error occurred. If your email is registered, please try again later."
                }
            }
        }
    }
} 