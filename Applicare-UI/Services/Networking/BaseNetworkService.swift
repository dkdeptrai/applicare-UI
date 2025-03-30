//
//  BaseNetworkService.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// The base network service that provides centralized API request handling
class BaseNetworkService: NetworkServiceProtocol {
    // Singleton instance
    static let shared = BaseNetworkService()
    
    // Private initialization to enforce singleton pattern
    private init() {}
    
    /// Perform a network request that returns a decodable object
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    ///   - body: Optional request body (for POST, PUT, etc.)
    ///   - completion: Completion handler with decoded result or error
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, body: Encodable? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        // Create URL from endpoint
        guard let url = endpoint.url() else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        
        // Add authentication header if needed
        if endpoint.requiresAuthentication {
            guard let token = AuthNetworkService.shared.getToken() else {
                completion(.failure(.unauthorized))
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add JSON body if provided
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.encodingFailed))
                return
            }
        }
        
        // Execute the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if error != nil {
                completion(.failure(.requestFailed))
                return
            }
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check for successful status code (200-299)
            let statusCode = httpResponse.statusCode
            if !(200...299).contains(statusCode) {
                // Try to extract error message if available
                var errorMessage: String?
                if let data = data {
                    errorMessage = try? JSONDecoder().decode(ErrorResponseDTO.self, from: data).error
                }
                
                completion(.failure(NetworkError(statusCode: statusCode, message: errorMessage)))
                return
            }
            
            // For Void responses (no content expected)
            if T.self == Void.self {
                completion(.success((() as! T)))
                return
            }
            
            // Handle missing data
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            // Decode the response
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    /// Perform a network request that doesn't return a response body
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    ///   - body: Optional request body (for POST, PUT, etc.)
    ///   - completion: Completion handler with success or error
    func request(_ endpoint: APIEndpointProtocol, body: Encodable? = nil, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        request(endpoint, body: body) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Empty response type for endpoints that don't return data
private struct EmptyResponse: Decodable {} 