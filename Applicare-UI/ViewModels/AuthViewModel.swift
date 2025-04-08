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
                    self?.errorMessage = "Registration successful! You can now log in."
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
                case .failure:
                    // If we can't fetch user details, log out
                    self?.authService.clearAuthData()
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
} 