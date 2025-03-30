//
//  AuthNetworkService.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// Protocol defining the authentication service functionality
protocol AuthNetworkServiceProtocol {
    func login(loginRequest: LoginRequestDTO, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void)
    func register(registerRequest: RegisterRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void)
    func verifyEmail(verifyRequest: VerifyEmailRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func resendVerification(resendRequest: ResendVerificationRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void)
    
    // Auth state management
    func setAuthData(token: String, userId: Int)
    func getToken() -> String?
    func getUserId() -> Int?
    func clearAuthData()
    func isUserLoggedIn() -> Bool
}

/// Service implementation for authentication-related API calls
class AuthNetworkService: AuthNetworkServiceProtocol {
    // Singleton instance
    static let shared = AuthNetworkService()
    
    // The base network service to use for requests
    private let networkService: NetworkServiceProtocol
    
    // Store local auth data
    private var authToken: String?
    private var userId: Int?
    
    // Private initialization to enforce singleton pattern
    private init(networkService: NetworkServiceProtocol = BaseNetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Authentication State Management
    
    /// Store JWT token and user ID
    func setAuthData(token: String, userId: Int) {
        self.authToken = token
        self.userId = userId
        UserDefaults.standard.set(token, forKey: "authToken")
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    /// Retrieve JWT token
    func getToken() -> String? {
        if authToken == nil {
            authToken = UserDefaults.standard.string(forKey: "authToken")
        }
        return authToken
    }
    
    /// Retrieve user ID
    func getUserId() -> Int? {
        if userId == nil {
            userId = UserDefaults.standard.integer(forKey: "userId")
            // If userId is 0, it means it wasn't set (default value for integer)
            if userId == 0 {
                userId = nil
            }
        }
        return userId
    }
    
    /// Clear auth data
    func clearAuthData() {
        authToken = nil
        userId = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
    }
    
    /// Check if user is logged in
    func isUserLoggedIn() -> Bool {
        return getToken() != nil && getUserId() != nil
    }
    
    // MARK: - API Methods
    
    /// Login user
    func login(loginRequest: LoginRequestDTO, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        networkService.request(.login, body: loginRequest) { [weak self] (result: Result<LoginResponseDTO, NetworkError>) in
            switch result {
            case .success(let response):
                self?.setAuthData(token: response.token, userId: response.user_id)
            case .failure:
                break
            }
            completion(result)
        }
    }
    
    /// Register new user
    func register(registerRequest: RegisterRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // The API expects a nested user object
        let registrationRequest = UserRegistrationDTO(
            user: UserRegistrationDTO.UserCreateDTO(
                email_address: registerRequest.email,
                password: registerRequest.password,
                password_confirmation: registerRequest.passwordConfirmation
            )
        )
        
        networkService.request(.register, body: registrationRequest, completion: completion)
    }
    
    /// Logout user
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkService.request(.logout, body: nil) { [weak self] result in
            // Even if the server logout fails, we still clear local auth data
            self?.clearAuthData()
            completion(result)
        }
    }
    
    /// Verify email with token
    func verifyEmail(verifyRequest: VerifyEmailRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let verificationRequest = EmailVerificationDTO(token: verifyRequest.token)
        networkService.request(.verifyEmail, body: verificationRequest, completion: completion)
    }
    
    /// Resend verification email
    func resendVerification(resendRequest: ResendVerificationRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let request = ResendVerificationDTO(email: resendRequest.email)
        networkService.request(.resendVerification, body: request, completion: completion)
    }
    
    // MARK: - Backwards compatibility methods
    
    /// Login user - Legacy interface
    func login(email: String, password: String, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        login(loginRequest: LoginRequestDTO(email: email, password: password), completion: completion)
    }
    
    /// Register new user - Legacy interface
    func register(email: String, password: String, passwordConfirmation: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        register(registerRequest: RegisterRequestDTO(email: email, password: password, passwordConfirmation: passwordConfirmation), completion: completion)
    }
    
    /// Verify email - Legacy interface
    func verifyEmail(token: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        verifyEmail(verifyRequest: VerifyEmailRequestDTO(token: token), completion: completion)
    }
    
    /// Resend verification - Legacy interface
    func resendVerification(email: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        resendVerification(resendRequest: ResendVerificationRequestDTO(email: email), completion: completion)
    }
} 