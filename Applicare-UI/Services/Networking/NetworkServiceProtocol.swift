//
//  NetworkServiceProtocol.swift
//  Applicare-UI
//

import Foundation

// Forward declaration of APIEndpoint, since both files need to reference each other
// We need to comment this out because Swift doesn't support forward declarations
// enum APIEndpoint { }

/// Protocol defining methods required for network services
protocol NetworkServiceProtocol {
    /// Request that returns a decodable object
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, body: Encodable?, completion: @escaping (Result<T, NetworkError>) -> Void)
    
    /// Request that doesn't return a response body
    func request(_ endpoint: APIEndpointProtocol, body: Encodable?, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

// Extension with default implementations
extension NetworkServiceProtocol {
    /// Request with no body
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, completion: @escaping (Result<T, NetworkError>) -> Void) {
        request(endpoint, body: nil, completion: completion)
    }
    
    /// Request with no body that doesn't return a response
    func request(_ endpoint: APIEndpointProtocol, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        request(endpoint, body: nil, completion: completion)
    }
} 