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
        networkService.request(APIEndpoint.login, body: loginRequest) { [weak self] (result: Result<LoginResponseDTO, NetworkError>) in
            switch result {
            case .success(let response):
                self?.setAuthData(token: response.token, userId: response.user_id)
                completion(result)
            case .failure(let error):
                switch error {
                case .unauthorized:
                    completion(.failure(.customError(message: "Invalid email or password")))
                default:
                    completion(.failure(error))
                }
            }
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
        
        networkService.request(APIEndpoint.register, body: registrationRequest, completion: completion)
    }
    
    /// Logout user
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // The API expects a session ID, but we'll use "current" as per the schema
        networkService.request(APIEndpoint.logout, body: nil) { [weak self] result in
            // Even if the server logout fails, we still clear local auth data
            self?.clearAuthData()
            completion(result)
        }
    }
} 