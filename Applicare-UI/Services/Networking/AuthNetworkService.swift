//
//  AuthNetworkService.swift
//  Applicare-UI
//

import Foundation

// MARK: - Notification Names
extension Notification.Name {
    static let userReauthenticationRequired = Notification.Name("UserReauthenticationRequired")
    static let repairerReauthenticationRequired = Notification.Name("RepairerReauthenticationRequired")
}

/// Protocol defining the authentication service functionality
protocol AuthNetworkServiceProtocol {
    func login(loginRequest: LoginRequestDTO, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void)
    func register(registerRequest: RegisterRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void)
    
    // Repairer auth methods
    func repairerLogin(loginRequest: LoginRequestDTO, completion: @escaping (Result<RepairerResponseDTO, NetworkError>) -> Void)
    func repairerRegister(registerRequest: RegisterRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func repairerLogout(completion: @escaping (Result<Void, NetworkError>) -> Void)
    
    // Auth state management
    func setAuthData(accessToken: String, refreshToken: String, expiresIn: Int, userId: Int)
    func getToken() -> String?
    func getRefreshToken() -> String?
    func getUserId() -> Int?
    func clearAuthData()
    func isUserLoggedIn() -> Bool
    
    // Repairer auth state management
    func setRepairerAuthData(accessToken: String, refreshToken: String, expiresIn: Int, repairerId: Int)
    func getRepairerToken() -> String?
    func getRepairerRefreshToken() -> String?
    func getRepairerId() -> Int?
    func clearRepairerAuthData()
    func isRepairerLoggedIn() -> Bool
    
    // Token refresh
    func refreshToken(completion: @escaping (Result<TokenRefreshResponseDTO, NetworkError>) -> Void)
}

/// Service implementation for authentication-related API calls
class AuthNetworkService: AuthNetworkServiceProtocol {
    // Singleton instance
    static let shared = AuthNetworkService()
    
    // The base network service to use for requests
    private let networkService: NetworkServiceProtocol
    
    // Store local auth data
    private var authToken: String?
    private var authRefreshToken: String?
    private var authTokenExpiry: Date?
    private var userId: Int?
    
    // Store repairer auth data
    private var repairerAuthToken: String?
    private var repairerRefreshToken: String?
    private var repairerTokenExpiry: Date?
    private var repairerId: Int?
    
    // Private initialization to enforce singleton pattern
    private init(networkService: NetworkServiceProtocol = BaseNetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Authentication State Management
    
    /// Store JWT token and user ID
    func setAuthData(accessToken: String, refreshToken: String, expiresIn: Int, userId: Int) {
        self.authToken = accessToken
        self.authRefreshToken = refreshToken
        self.userId = userId
        
        // Calculate the expiry date
        self.authTokenExpiry = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        // Store in UserDefaults
        UserDefaults.standard.set(accessToken, forKey: "authToken")
        UserDefaults.standard.set(refreshToken, forKey: "authRefreshToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(self.authTokenExpiry, forKey: "authTokenExpiry")
    }
    
    /// Retrieve JWT token
    func getToken() -> String? {
        if authToken == nil {
            authToken = UserDefaults.standard.string(forKey: "authToken")
            authTokenExpiry = UserDefaults.standard.object(forKey: "authTokenExpiry") as? Date
        }
        
        // Check if token is expired
        if let expiry = authTokenExpiry, expiry < Date() {
            // Return nil to trigger token refresh flow
            return nil
        }
        
        return authToken
    }
    
    /// Retrieve refresh token
    func getRefreshToken() -> String? {
        if authRefreshToken == nil {
            authRefreshToken = UserDefaults.standard.string(forKey: "authRefreshToken")
        }
        return authRefreshToken
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
        authRefreshToken = nil
        authTokenExpiry = nil
        userId = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "authRefreshToken")
        UserDefaults.standard.removeObject(forKey: "authTokenExpiry")
        UserDefaults.standard.removeObject(forKey: "userId")
    }
    
    /// Check if user is logged in
    func isUserLoggedIn() -> Bool {
        return getToken() != nil && getUserId() != nil
    }
    
    // MARK: - Repairer Authentication State Management
    
    func setRepairerAuthData(accessToken: String, refreshToken: String, expiresIn: Int, repairerId: Int) {
        self.repairerAuthToken = accessToken
        self.repairerRefreshToken = refreshToken
        self.repairerId = repairerId
        
        // Calculate the expiry date
        self.repairerTokenExpiry = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        // Store in UserDefaults
        UserDefaults.standard.set(accessToken, forKey: "repairerAuthToken")
        UserDefaults.standard.set(refreshToken, forKey: "repairerRefreshToken")
        UserDefaults.standard.set(repairerId, forKey: "repairerId")
        UserDefaults.standard.set(self.repairerTokenExpiry, forKey: "repairerTokenExpiry")
    }
    
    func getRepairerToken() -> String? {
        if repairerAuthToken == nil {
            repairerAuthToken = UserDefaults.standard.string(forKey: "repairerAuthToken")
            repairerTokenExpiry = UserDefaults.standard.object(forKey: "repairerTokenExpiry") as? Date
        }
        
        // Check if token is expired
        if let expiry = repairerTokenExpiry, expiry < Date() {
            // Return nil to trigger token refresh flow
            return nil
        }
        
        return repairerAuthToken
    }
    
    func getRepairerRefreshToken() -> String? {
        if repairerRefreshToken == nil {
            repairerRefreshToken = UserDefaults.standard.string(forKey: "repairerRefreshToken")
        }
        return repairerRefreshToken
    }
    
    func getRepairerId() -> Int? {
        if repairerId == nil {
            repairerId = UserDefaults.standard.integer(forKey: "repairerId")
            if repairerId == 0 {
                repairerId = nil
            }
        }
        return repairerId
    }
    
    func clearRepairerAuthData() {
        repairerAuthToken = nil
        repairerRefreshToken = nil
        repairerTokenExpiry = nil
        repairerId = nil
        UserDefaults.standard.removeObject(forKey: "repairerAuthToken")
        UserDefaults.standard.removeObject(forKey: "repairerRefreshToken")
        UserDefaults.standard.removeObject(forKey: "repairerTokenExpiry")
        UserDefaults.standard.removeObject(forKey: "repairerId")
    }
    
    func isRepairerLoggedIn() -> Bool {
        return getRepairerToken() != nil && getRepairerId() != nil
    }
    
    // MARK: - Token Refresh
    
    func refreshToken(completion: @escaping (Result<TokenRefreshResponseDTO, NetworkError>) -> Void) {
        // Determine which refresh token to use
        let refreshToken: String?
        let isRepairerRefresh: Bool
        
        if getRepairerRefreshToken() != nil {
            refreshToken = getRepairerRefreshToken()
            isRepairerRefresh = true
        } else if getRefreshToken() != nil {
            refreshToken = getRefreshToken()
            isRepairerRefresh = false
        } else {
            completion(.failure(.unauthorized))
            return
        }
        
        guard let token = refreshToken else {
            completion(.failure(.unauthorized))
            return
        }
        
        let requestDTO = TokenRefreshRequestDTO(refresh_token: token)
        
        #if DEBUG
        print("🔄 Refreshing token: \(isRepairerRefresh ? "Repairer" : "User")")
        #endif
        
        networkService.request(APIEndpoint.refreshToken, body: requestDTO) { [weak self] (result: Result<TokenRefreshResponseDTO, NetworkError>) in
            switch result {
            case .success(let response):
                #if DEBUG
                print("✅ Token refresh successful. New token expires in \(response.expires_in) seconds")
                #endif
                
                // Update the appropriate token storage
                if isRepairerRefresh, let repairerId = self?.getRepairerId() {
                    self?.setRepairerAuthData(
                        accessToken: response.access_token,
                        refreshToken: response.refresh_token,
                        expiresIn: response.expires_in,
                        repairerId: repairerId
                    )
                } else if let userId = self?.getUserId() {
                    self?.setAuthData(
                        accessToken: response.access_token,
                        refreshToken: response.refresh_token, 
                        expiresIn: response.expires_in,
                        userId: userId
                    )
                }
                completion(.success(response))
            case .failure(let error):
                #if DEBUG
                print("❌ Token refresh failed: \(error.localizedDescription)")
                #endif
                
                // If refresh fails, might need to re-authenticate
                if case .unauthorized = error {
                    // Clear tokens but keep IDs for now
                    if isRepairerRefresh {
                        self?.repairerAuthToken = nil
                        self?.repairerRefreshToken = nil
                        UserDefaults.standard.removeObject(forKey: "repairerAuthToken")
                        UserDefaults.standard.removeObject(forKey: "repairerRefreshToken")
                    } else {
                        self?.authToken = nil
                        self?.authRefreshToken = nil
                        UserDefaults.standard.removeObject(forKey: "authToken")
                        UserDefaults.standard.removeObject(forKey: "authRefreshToken")
                    }
                    
                    // Post notification for authentication required
                    NotificationCenter.default.post(
                        name: isRepairerRefresh ? .repairerReauthenticationRequired : .userReauthenticationRequired,
                        object: nil
                    )
                }
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - API Methods
    
    /// Login user
    func login(loginRequest: LoginRequestDTO, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.login, body: loginRequest) { [weak self] (result: Result<LoginResponseDTO, NetworkError>) in
            switch result {
            case .success(let response):
                self?.setAuthData(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token,
                    expiresIn: response.expires_in,
                    userId: response.user_id
                )
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
                name: registerRequest.name,
                email_address: registerRequest.email_address,
                password: registerRequest.password,
                password_confirmation: registerRequest.passwordConfirmation
            )
        )
        
        networkService.request(APIEndpoint.register, body: registrationRequest, completion: completion)
    }
    
    /// Logout user
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // Get the current user ID
        guard let userId = getUserId() else {
            // If no user ID, maybe they are already logged out? Clear local data anyway.
            clearAuthData()
            completion(.failure(.customError(message: "User not logged in or ID missing")))
            return
        }
        
        // Pass the user ID to the logout endpoint
        networkService.request(APIEndpoint.logout(id: userId), body: nil) { [weak self] result in
            // Even if the server logout fails, we still clear local auth data
            self?.clearAuthData()
            completion(result)
        }
    }
    
    // MARK: - Repairer API Methods
    
    func repairerLogin(loginRequest: LoginRequestDTO, completion: @escaping (Result<RepairerResponseDTO, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.repairerLogin, body: loginRequest) { [weak self] (result: Result<RepairerResponseDTO, NetworkError>) in
            switch result {
            case .success(let response):
                self?.setRepairerAuthData(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token,
                    expiresIn: response.expires_in,
                    repairerId: response.repairer.id
                )
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
    
    func repairerRegister(registerRequest: RegisterRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let registrationRequest = UserRegistrationDTO(
            user: UserRegistrationDTO.UserCreateDTO(
                name: registerRequest.name,
                email_address: registerRequest.email_address,
                password: registerRequest.password,
                password_confirmation: registerRequest.passwordConfirmation
            )
        )
        
        networkService.request(APIEndpoint.repairerRegister, body: registrationRequest, completion: completion)
    }
    
    func repairerLogout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let repairerId = getRepairerId() else {
            clearRepairerAuthData()
            completion(.failure(.customError(message: "Repairer not logged in or ID missing")))
            return
        }
        
        networkService.request(APIEndpoint.repairerLogout(id: repairerId), body: nil) { [weak self] result in
            self?.clearRepairerAuthData()
            completion(result)
        }
    }
} 