import Foundation
import SwiftUI

class RepairerAuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentRepairer: Repairer? = nil
    
    private let authService: AuthNetworkServiceProtocol
    
    init(authService: AuthNetworkServiceProtocol = AuthNetworkService.shared) {
        self.authService = authService
        
        // Check if repairer is already logged in
        isAuthenticated = authService.isRepairerLoggedIn()
        
        // If authenticated, fetch profile data
        if isAuthenticated {
            fetchProfileData()
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequestDTO(email_address: email, password: password)
        
        authService.repairerLogin(loginRequest: loginRequest) { [weak self] result in
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
        
        let registerRequest = RegisterRequestDTO(name: name, email_address: email, password: password, passwordConfirmation: confirmPassword)
        
        authService.repairerRegister(registerRequest: registerRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.errorMessage = "Registration successful! Please sign in."
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
        
        authService.repairerLogout { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.authService.clearRepairerAuthData()
                self?.isAuthenticated = false
                self?.currentRepairer = nil
                
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
        // TODO: Implement repairer profile fetch
        // This will be implemented when the repairer profile endpoint is available
    }
} 