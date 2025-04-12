//
//  UserNetworkService.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// Protocol defining the user service functionality
protocol UserNetworkServiceProtocol {
    func getCurrentUser(completion: @escaping (Result<UserDTO, NetworkError>) -> Void)
    func getUser(id: Int, completion: @escaping (Result<UserDTO, NetworkError>) -> Void)
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
    
    /// Get the current authenticated user
    func getCurrentUser(completion: @escaping (Result<UserDTO, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getCurrentUser, body: nil, completion: completion)
    }
    
    /// Get a specific user by ID
    func getUser(id: Int, completion: @escaping (Result<UserDTO, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getUser(id: id), body: nil, completion: completion)
    }
} 