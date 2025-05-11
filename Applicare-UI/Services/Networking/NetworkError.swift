//
//  NetworkError.swift
//  Applicare-UI
//

import Foundation

/// Standard network errors that can occur during API requests
enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case encodingFailed
    case invalidResponse
    case unauthorized
    case badRequest
    case notFound
    case serverError
    case validationError(message: String)
    case customError(message: String)
    
    // HTTP status code mapping
    init(statusCode: Int, message: String? = nil) {
        switch statusCode {
        case 400:
            self = .badRequest
        case 401, 403:
            self = .unauthorized
        case 404:
            self = .notFound
        case 422:
            self = .validationError(message: message ?? "Validation failed")
        case 500...599:
            self = .serverError
        default:
            self = .customError(message: message ?? "Unknown error occurred")
        }
    }
    
    // User-friendly error message
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Network request failed"
        case .decodingFailed:
            return "Failed to decode response"
        case .encodingFailed:
            return "Failed to encode request data"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication failed"
        case .badRequest:
            return "The request was invalid"
        case .notFound:
            return "The requested resource was not found"
        case .serverError:
            return "Server error occurred"
        case .validationError(let message):
            return message
        case .customError(let message):
            return message
        }
    }
} 