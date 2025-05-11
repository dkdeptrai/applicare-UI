//
//  APIEndpoint.swift
//  Applicare-UI
//

import Foundation

/// Represents all API endpoints in the application
enum APIEndpoint: APIEndpointProtocol {
    // Base API URL - Consider making this configurable per environment
    #if DEBUG
    // In debug, check for environment variable or use default local server
    static let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://127.0.0.1:3000/api/v1"
    #else
    // Production URL would be set here for release builds
    static let baseURL = "https://api.applicare.com/api/v1"
    #endif
    
    // Log endpoint info for debugging
    static func logEndpoint(_ endpoint: APIEndpoint, method: String, url: String) {
        #if DEBUG
        print("📡 API REQUEST: \(method) \(url)")
        #endif
    }
    
    // Auth endpoints
    case login
    case logout(id: Int)
    case register
    
    // Repairer auth endpoints
    case repairerLogin
    case repairerLogout(id: Int)
    case repairerRegister
    
    // User endpoints
    case getCurrentUser
    case getUser(id: Int)
    case getProfile
    case updateProfile
    
    // Booking endpoints
    case getAllBookings
    case createBooking
    case getBooking(id: Int)
    case updateBooking(id: Int)
    case cancelBooking(id: Int)
    
    // Repairer booking endpoints
    case getRepairerBookings(status: String?, startDate: String?, endDate: String?)
    case getRepairerBooking(id: Int)
    case updateRepairerBookingStatus(id: Int, status: String)
    case addRepairerBookingNote(id: Int, note: String)
    
    // Chat endpoints
    case getMessages(bookingId: Int)
    case sendMessage
    
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
            
        // Repairer auth endpoints
        case .repairerLogin:
            return "\(APIEndpoint.baseURL)/repairer_sessions"
        case .repairerLogout(let id):
            return "\(APIEndpoint.baseURL)/repairer_sessions/\(id)"
        case .repairerRegister:
            return "\(APIEndpoint.baseURL)/repairers"
            
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
        case .updateProfile:
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
            
        // Repairer booking endpoints
        case .getRepairerBookings(let status, let startDate, let endDate):
            var components = URLComponents(string: "\(APIEndpoint.baseURL)/repairer/bookings")
            var queryItems: [URLQueryItem] = []
            
            if let status = status {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
            
            if let startDate = startDate {
                queryItems.append(URLQueryItem(name: "start_date", value: startDate))
            }
            
            if let endDate = endDate {
                queryItems.append(URLQueryItem(name: "end_date", value: endDate))
            }
            
            if !queryItems.isEmpty {
                components?.queryItems = queryItems
            }
            
            return components?.string ?? "\(APIEndpoint.baseURL)/repairer/bookings"
        case .getRepairerBooking(let id):
            return "\(APIEndpoint.baseURL)/repairer/bookings/\(id)"
        case .updateRepairerBookingStatus(let id, _):
            return "\(APIEndpoint.baseURL)/repairer/bookings/\(id)"
        case .addRepairerBookingNote(let id, _):
            return "\(APIEndpoint.baseURL)/repairer/bookings/\(id)/notes"
            
        // Chat endpoints
        case .getMessages(let bookingId):
            return "\(APIEndpoint.baseURL)/bookings/\(bookingId)/messages"
        case .sendMessage:
            return "\(APIEndpoint.baseURL)/messages"
            
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
        // POST Methods
        case .login, .register, .createBooking, .sendMessage,
             .repairerLogin, .repairerRegister, .addRepairerBookingNote:
            return "POST"
            
        // DELETE Methods
        case .logout, .cancelBooking, .repairerLogout:
            return "DELETE"
            
        // PUT Methods
        case .updateBooking, .updateProfile:
            return "PUT"
            
        // PATCH Methods
        case .updateRepairerBookingStatus:
            return "PATCH"
            
        // GET Methods
        case .getCurrentUser, .getUser, .getProfile, 
             .getAllBookings, .getBooking, .getMessages,
             .getRepairerCalendar, .getNearbyRepairers,
             .getRepairerBookings, .getRepairerBooking:
            return "GET"
        }
        // No default needed as all cases should be covered
    }
    
    // Indicates if the endpoint requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .login, .register, .repairerLogin, .repairerRegister:
            return false
        case .logout, .getCurrentUser, .getUser,
             .getAllBookings, .createBooking, .getBooking, .updateBooking, .cancelBooking,
             .getProfile, .updateProfile, .getMessages, .sendMessage,
             .getRepairerCalendar, .getNearbyRepairers,
             .repairerLogout, .getRepairerBookings, .getRepairerBooking, .updateRepairerBookingStatus, .addRepairerBookingNote:
            return true
        }
        // No default needed as all cases are now covered
    }
    
    // Returns a URL from the endpoint's URL string
    func url() -> URL? {
        let url = URL(string: urlString)
        APIEndpoint.logEndpoint(self, method: httpMethod, url: urlString)
        return url
    }
} 