//
//  APIEndpoint.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// Represents all API endpoints in the application
enum APIEndpoint: APIEndpointProtocol {
    // Base API URL
    static let baseURL = "http://127.0.0.1:3000/api/v1"
    
    // Auth endpoints
    case login
    case logout
    case register
    
    // User endpoints
    case getCurrentUser
    case getUser(id: Int)
    case getUsers
    
    // Computed property that returns the full URL string
    var urlString: String {
        switch self {
        // Auth endpoints
        case .login:
            return "\(APIEndpoint.baseURL)/sessions"
        case .logout:
            return "\(APIEndpoint.baseURL)/sessions/current"
        case .register:
            return "\(APIEndpoint.baseURL)/users"
            
        // User endpoints
        case .getCurrentUser:
            if let userId = AuthNetworkService.shared.getUserId() {
                return "\(APIEndpoint.baseURL)/users/\(userId)"
            } else {
                return "\(APIEndpoint.baseURL)/users/me"
            }
        case .getUser(let id):
            return "\(APIEndpoint.baseURL)/users/\(id)"
        case .getUsers:
            return "\(APIEndpoint.baseURL)/users"
        }
    }
    
    // Returns the HTTP method for this endpoint
    var httpMethod: String {
        switch self {
        case .login, .register:
            return "POST"
        case .logout:
            return "DELETE"
        case .getCurrentUser, .getUser, .getUsers:
            return "GET"
        }
    }
    
    // Indicates if the endpoint requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .login, .register:
            return false
        case .logout, .getCurrentUser, .getUser, .getUsers:
            return true
        }
    }
    
    // Returns a URL from the endpoint's URL string
    func url() -> URL? {
        return URL(string: urlString)
    }
} 