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
    case logout(id: Int)
    case register
    
    // User endpoints
    case getCurrentUser
    case getUser(id: Int)
    case getProfile
    
    // Booking endpoints
    case getAllBookings
    case createBooking
    case getBooking(id: Int)
    case updateBooking(id: Int)
    case cancelBooking(id: Int)
    
    // Repairer endpoints
    case getRepairerCalendar(repairerId: Int, year: Int, month: Int)
    case getNearbyRepairers(latitude: Double, longitude: Double, radius: Double?)
    
    // Computed property that returns the full URL string
    var urlString: String {
        switch self {
        // Auth endpoints
        case .login:
            return "\(APIEndpoint.baseURL)/sessions"
        case .logout(let id):
            return "\(APIEndpoint.baseURL)/sessions/\(id)"
        case .register:
            return "\(APIEndpoint.baseURL)/users"
            
        // User endpoints
        case .getCurrentUser:
            if let userId = AuthNetworkService.shared.getUserId() {
                return "\(APIEndpoint.baseURL)/users/\(userId)"
            } else {
                print("Error: Attempted to get current user URL without a user ID.")
                return "\(APIEndpoint.baseURL)/users/error_no_user_id"
            }
        case .getUser(let id):
            return "\(APIEndpoint.baseURL)/users/\(id)"
        case .getProfile:
            return "\(APIEndpoint.baseURL)/profile"
            
        // Booking endpoints
        case .getAllBookings:
            return "\(APIEndpoint.baseURL)/bookings"
        case .createBooking:
            return "\(APIEndpoint.baseURL)/bookings"
        case .getBooking(let id):
            return "\(APIEndpoint.baseURL)/bookings/\(id)"
        case .updateBooking(let id):
            return "\(APIEndpoint.baseURL)/bookings/\(id)"
        case .cancelBooking(let id):
            return "\(APIEndpoint.baseURL)/bookings/\(id)"
            
        // Repairer endpoints
        case .getRepairerCalendar(let repairerId, let year, let month):
            return "\(APIEndpoint.baseURL)/repairers/\(repairerId)/calendar/\(year)/\(month)"
        case .getNearbyRepairers(let latitude, let longitude, let radius):
            var queryItems = [URLQueryItem(name: "latitude", value: "\(latitude)"), URLQueryItem(name: "longitude", value: "\(longitude)")]
            if let radius = radius {
                queryItems.append(URLQueryItem(name: "radius", value: "\(radius)"))
            }
            var components = URLComponents(string: "\(APIEndpoint.baseURL)/repairers/nearby")
            components?.queryItems = queryItems
            return components?.string ?? ""
        }
    }
    
    // Returns the HTTP method for this endpoint
    var httpMethod: String {
        switch self {
        case .login, .register, .createBooking:
            return "POST"
        case .logout( _), .cancelBooking( _):
            return "DELETE"
        case .getCurrentUser, .getUser( _), .getAllBookings, .getBooking( _):
            return "GET"
        case .updateBooking( _):
            return "PUT"
        case .getProfile:
            return "GET"
        case .getRepairerCalendar( _, _, _), .getNearbyRepairers( _, _, _):
            return "GET"
        }
    }
    
    // Indicates if the endpoint requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .login, .register:
            return false
        case .logout( _), .getCurrentUser, .getUser( _),
             .getAllBookings, .createBooking, .getBooking( _), .updateBooking( _), .cancelBooking( _),
             .getProfile, .getRepairerCalendar( _, _, _), .getNearbyRepairers( _, _, _):
            return true
        }
    }
    
    // Returns a URL from the endpoint's URL string
    func url() -> URL? {
        return URL(string: urlString)
    }
} 