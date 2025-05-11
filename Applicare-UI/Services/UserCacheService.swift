//
//  UserCacheService.swift
//  Applicare-UI
//

import Foundation

/// Service for caching user data to avoid repeated API calls
class UserCacheService {
    // Singleton instance
    static let shared = UserCacheService()
    
    // The user network service
    private let userService: UserNetworkServiceProtocol
    
    // Cache for user data
    private var userCache: [Int: User] = [:]
    
    // Private initialization to enforce singleton pattern
    private init(userService: UserNetworkServiceProtocol = UserNetworkService.shared) {
        self.userService = userService
    }
    
    /// Get a user by ID, either from cache or API
    /// - Parameters:
    ///   - id: The user ID
    ///   - completion: Completion handler with user or error
    func getUser(id: Int, completion: @escaping (Result<User, NetworkError>) -> Void) {
        // Check if user is in cache
        if let cachedUser = userCache[id] {
            completion(.success(cachedUser))
            return
        }
        
        // Fetch from API
        userService.getUser(id: id) { [weak self] result in
            switch result {
            case .success(let user):
                // Cache the user
                self?.userCache[id] = user
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Get user name by ID, with a fallback if not available
    /// - Parameters:
    ///   - id: The user ID (optional)
    ///   - completion: Completion handler with the user's name
    func getUserName(id: Int?, completion: @escaping (String) -> Void) {
        // If ID is nil, return generic name
        guard let id = id else {
            completion("Unknown Customer")
            return
        }
        
        getUser(id: id) { result in
            switch result {
            case .success(let user):
                completion(user.name)
            case .failure:
                // Fallback to a placeholder name
                completion("Customer #\(id)")
            }
        }
    }
    
    /// Clear the user cache
    func clearCache() {
        userCache.removeAll()
    }
} 