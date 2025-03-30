//
//  APIEndpointProtocol.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

/// Protocol that defines what an API endpoint should provide
protocol APIEndpointProtocol {
    /// The full URL string for the endpoint
    var urlString: String { get }
    
    /// The HTTP method for this endpoint
    var httpMethod: String { get }
    
    /// Indicates if the endpoint requires authentication
    var requiresAuthentication: Bool { get }
    
    /// Returns a URL from the endpoint's URL string
    func url() -> URL?
} 