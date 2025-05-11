//
//  BaseNetworkService.swift
//  Applicare-UI
//

import Foundation

/// The base network service that provides centralized API request handling
class BaseNetworkService: NetworkServiceProtocol {
    // Singleton instance
    static let shared = BaseNetworkService()
    
    // Private initialization to enforce singleton pattern
    private init() {}
    
    // Flag to track if a token refresh is in progress to prevent multiple simultaneous refresh attempts
    private var isRefreshingToken = false
    
    // Queue of pending requests waiting for token refresh
    private var pendingRequests: [(APIEndpointProtocol, Encodable?, Any)] = []
    
    /// Perform a network request that returns a decodable object
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    ///   - body: Optional request body (for POST, PUT, etc.)
    ///   - completion: Completion handler with decoded result or error
    func request<T: Decodable>(_ endpoint: APIEndpointProtocol, body: Encodable? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        // Skip token refresh for the refresh token endpoint itself
        if let apiEndpoint = endpoint as? APIEndpoint, case .refreshToken = apiEndpoint {
            performRequest(endpoint, body: body, completion: completion)
            return
        }
        
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
            // Check if token is expired (implemented in AuthNetworkService)
            let isTokenExpired = isCurrentTokenExpired()
            
            // If token is expired, try to refresh it before making the request
            if isTokenExpired {
                enqueueRequestForTokenRefresh(endpoint, body: body, completion: completion)
                return
            }
            
            // Get the active token - prioritize repairer token if logged in as repairer
            let token = AuthNetworkService.shared.getRepairerToken() ?? AuthNetworkService.shared.getToken()
            
            // If no token and authentication is required, try to refresh
            if token == nil {
                enqueueRequestForTokenRefresh(endpoint, body: body, completion: completion)
                return
            }
            
            guard let token = token else {
                completion(.failure(.unauthorized))
                return
            }
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        performRequest(endpoint, body: body, originalRequest: endpoint, originalBody: body, completion: completion)
    }
    
    // Helper method to check if current token is expired
    private func isCurrentTokenExpired() -> Bool {
        // Check repairer token first, then user token
        if AuthNetworkService.shared.isRepairerLoggedIn(), 
           let expiry = UserDefaults.standard.object(forKey: "repairerTokenExpiry") as? Date,
           expiry < Date() {
            return true
        }
        
        if AuthNetworkService.shared.isUserLoggedIn(),
           let expiry = UserDefaults.standard.object(forKey: "authTokenExpiry") as? Date,
           expiry < Date() {
            return true
        }
        
        return false
    }
    
    // Helper method to queue requests that need to wait for token refresh
    private func enqueueRequestForTokenRefresh<T: Decodable>(_ endpoint: APIEndpointProtocol, body: Encodable? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        // Add request to pending queue
        pendingRequests.append((endpoint, body, completion as Any))
        
        // If already refreshing, just queue the request
        if isRefreshingToken {
            return
        }
        
        // Set refreshing flag and start the refresh
        isRefreshingToken = true
        
        // Try to refresh the token
        tryRefreshToken { [weak self] refreshResult in
            guard let self = self else { return }
            
            // Mark refresh as complete
            self.isRefreshingToken = false
            
            switch refreshResult {
            case .success:
                // Process all pending requests with new token
                self.processPendingRequests()
            case .failure(let error):
                // Fail all pending requests with the same error
                self.failAllPendingRequests(with: error)
            }
        }
    }
    
    // Process all pending requests after token refresh
    private func processPendingRequests() {
        let requests = pendingRequests
        pendingRequests = []
        
        for (endpoint, body, completion) in requests {
            if let completionHandler = completion as? (Result<Void, NetworkError>) -> Void {
                request(endpoint, body: body, completion: completionHandler)
            } else {
                // For non-Void completion handlers, we need to use correct generic type
                performGenericRequest(endpoint, body: body, completion: completion)
            }
        }
    }
    
    // Helper method to handle generic request types
    private func performGenericRequest(_ endpoint: APIEndpointProtocol, body: Encodable?, completion: Any) {
        // Since we can't know the exact type at runtime, we need to handle failure cases at minimum
        if let completionHandler = completion as? (Result<Void, NetworkError>) -> Void {
            // Already handled in the calling method, but double-check
            request(endpoint, body: body, completion: completionHandler)
        } else {
            // For any other type, we'll make a request with a flexible JSON structure
            // and then fail the original completion with a custom error if needed
            request(endpoint, body: body) { (result: Result<EmptyResponse, NetworkError>) in
                if case .failure(let error) = result {
                    // Try to pass the error to the original completion
                    if let anyCompletion = completion as? ((Result<Any, NetworkError>) -> Void) {
                        anyCompletion(.failure(error))
                    } else {
                        print("Warning: Unable to pass error to completion handler of unknown type")
                    }
                } else {
                    print("Request succeeded but handler type mismatch - implement specific type handling if needed")
                }
            }
        }
    }
    
    // Fail all pending requests with the same error
    private func failAllPendingRequests(with error: NetworkError) {
        let requests = pendingRequests
        pendingRequests = []
        
        for (_, _, completion) in requests {
            if let completionHandler = completion as? (Result<Void, NetworkError>) -> Void {
                completionHandler(.failure(error))
            } else if let completionHandler = completion as? (Result<Any, NetworkError>) -> Void {
                completionHandler(.failure(error))
            }
        }
    }
    
    // Helper method to perform the actual network request
    private func performRequest<T: Decodable>(_ endpoint: APIEndpointProtocol, body: Encodable? = nil, originalRequest: APIEndpointProtocol? = nil, originalBody: Encodable? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
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
            // Get the active token - prioritize repairer token if logged in as repairer
            let token = AuthNetworkService.shared.getRepairerToken() ?? AuthNetworkService.shared.getToken()
            
            guard let token = token else {
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
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                
                // Special handling for unauthorized errors (401)
                if statusCode == 401, let originalRequest = originalRequest, let self = self {
                    // Try to refresh the token
                    self.tryRefreshToken { refreshResult in
                        switch refreshResult {
                        case .success:
                            // Retry the original request with the new token
                            self.request(originalRequest, body: originalBody, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    return
                }
                
                completion(.failure(NetworkError(statusCode: statusCode, message: errorMessage)))
                return
            }
            
            // For Void responses (no content expected)
            if T.self == Void.self {
                completion(.success((()) as! T))
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
    
    // Helper method to try refreshing the token
    private func tryRefreshToken(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // Try to get a refresh token
        let refreshToken: String?
        
        if let token = AuthNetworkService.shared.getRepairerRefreshToken() {
            refreshToken = token
        } else if let token = AuthNetworkService.shared.getRefreshToken() {
            refreshToken = token
        } else {
            completion(.failure(.unauthorized))
            return
        }
        
        guard let token = refreshToken else {
            completion(.failure(.unauthorized))
            return
        }
        
        let requestDTO = TokenRefreshRequestDTO(refresh_token: token)
        
        // Call the token refresh endpoint
        let refreshEndpoint = APIEndpoint.refreshToken
        
        // Make raw request to avoid recursion
        performRequest(refreshEndpoint, body: requestDTO) { (result: Result<TokenRefreshResponseDTO, NetworkError>) in
            switch result {
            case .success(_):
                // Token was refreshed and stored by the AuthNetworkService
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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