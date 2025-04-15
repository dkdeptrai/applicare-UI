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
    func updateProfile(name: String, dateOfBirth: String, mobileNumber: String, address: String, completion: @escaping (Result<User, NetworkError>) -> Void) // Added
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
    
    /// Update the profile of the currently authenticated user
    func updateProfile(name: String, dateOfBirth: String, mobileNumber: String, address: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        // Create profile update payload
        let updateData = [
            "user": [
                "name": name,
                "date_of_birth": dateOfBirth,
                "mobile_number": mobileNumber,
                "address": address
            ]
        ]
        
        networkService.request(APIEndpoint.updateProfile, body: updateData, completion: completion)
    }
} 