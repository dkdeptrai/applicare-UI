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
        
        // If authenticated, fetch profile data
        if isAuthenticated {
            fetchProfileData()
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequestDTO(email_address: email, password: password)
        
        authService.login(loginRequest: loginRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    self?.isAuthenticated = true
                    self?.fetchProfileData()
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
    
    func signUp(name: String, email: String, password: String, confirmPassword: String) {
        isLoading = true
        errorMessage = nil
        
        let registerRequest = RegisterRequestDTO(name: name, email: email, password: password, passwordConfirmation: confirmPassword)
        
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
                self?.authService.clearAuthData()
                self?.isAuthenticated = false
                self?.currentUser = nil

                switch result {
                case .success:
                    print("Logout successful")
                case .failure(let error):
                    print("Server logout failed: \(error.localizedDescription)")
                    self?.errorMessage = "Server logout failed, but you are logged out locally."
                }
            }
        }
    }
    
    func fetchProfileData() {
        isLoading = true
        errorMessage = nil
        
        userService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    print("Successfully fetched profile for user: \(user.name)")
                case .failure(let error):
                    print("Failed to fetch profile: \(error.localizedDescription)")
                    self?.errorMessage = "Could not fetch your profile. Please try logging in again."
                    self?.authService.clearAuthData()
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
} 