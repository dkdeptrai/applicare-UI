//
//  UserNetworkService.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// Protocol defining the user service functionality
protocol UserNetworkServiceProtocol {
    // func getCurrentUser(completion: @escaping (Result<UserDTO, NetworkError>) -> Void) // Deprecate or remove if profile replaces it
    func getUser(id: Int, completion: @escaping (Result<User, NetworkError>) -> Void) // Changed DTO to User
    func fetchProfile(completion: @escaping (Result<User, NetworkError>) -> Void) // Added
    // func updateProfile(userInfo: UpdateProfileDTO, completion: @escaping (Result<User, NetworkError>) -> Void) // REMOVED
}

/// Service implementation for user-related API calls
class UserNetworkService: UserNetworkServiceProtocol {
    // Singleton instance
    static let shared = UserNetworkService()
    
    // The base network service to use for requests
    private let networkService: NetworkServiceProtocol
    
    // Private initialization to enforce singleton pattern
    private init(networkService: NetworkServiceProtocol = BaseNetworkService.shared) {
        self.networkService = networkService
    }
    
    /* // Deprecate or remove if fetchProfile is preferred
    func getCurrentUser(completion: @escaping (Result<UserDTO, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getCurrentUser, body: nil, completion: completion)
    }
    */
    
    /// Fetch the profile of the currently authenticated user
    func fetchProfile(completion: @escaping (Result<User, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getProfile, body: nil, completion: completion)
    }
    
    /// Get a specific user by ID (updated to return User)
    func getUser(id: Int, completion: @escaping (Result<User, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getUser(id: id), body: nil, completion: completion)
    }
    
    // Removed implementation for updating profile
    /*
    func updateProfile(userInfo: UpdateProfileDTO, completion: @escaping (Result<User, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.updateProfile, body: userInfo, completion: completion)
    }
    */
} 