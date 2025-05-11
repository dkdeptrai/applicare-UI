//
//  BookingNetworkService.swift
//  Applicare-UI
//

import Foundation

protocol BookingNetworkServiceProtocol {
    func getAllBookings(completion: @escaping (Result<[Booking], NetworkError>) -> Void)
    func createBooking(request: CreateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 201 returns no body
    func getBooking(id: Int, completion: @escaping (Result<Booking, NetworkError>) -> Void)
    func updateBooking(id: Int, request: UpdateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 200 returns no body
    func cancelBooking(id: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 204 returns no body
    
    // Repairer booking methods
    func getRepairerBookings(status: String?, startDate: String?, endDate: String?, completion: @escaping (Result<[Booking], NetworkError>) -> Void)
    func getRepairerBooking(id: Int, completion: @escaping (Result<Booking, NetworkError>) -> Void)
    func updateRepairerBookingStatus(id: Int, status: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func addRepairerBookingNote(id: Int, note: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

class BookingNetworkService: BookingNetworkServiceProtocol {
    static let shared = BookingNetworkService()
    private let networkService: NetworkServiceProtocol
    
    private init(networkService: NetworkServiceProtocol = BaseNetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAllBookings(completion: @escaping (Result<[Booking], NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getAllBookings, body: nil, completion: completion)
    }
    
    func createBooking(request: CreateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.createBooking, body: request, completion: completion)
    }
    
    func getBooking(id: Int, completion: @escaping (Result<Booking, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getBooking(id: id), body: nil, completion: completion)
    }
    
    func updateBooking(id: Int, request: UpdateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.updateBooking(id: id), body: request, completion: completion)
    }
    
    func cancelBooking(id: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.cancelBooking(id: id), body: nil, completion: completion)
    }
    
    // MARK: - Repairer Booking Methods
    
    func getRepairerBookings(status: String? = nil, startDate: String? = nil, endDate: String? = nil, completion: @escaping (Result<[Booking], NetworkError>) -> Void) {
        // Debug: Print the URL that will be requested
        let endpoint = APIEndpoint.getRepairerBookings(status: status, startDate: startDate, endDate: endDate)
        print("🔍 DEBUG: Requesting repairer bookings from URL: \(endpoint.urlString)")
        
        // Debug: Check if any authentication token exists
        if let token = AuthNetworkService.shared.getRepairerToken() ?? AuthNetworkService.shared.getToken() {
            print("✅ Authentication token found: \(token)")
        } else {
            print("⚠️ WARNING: No authentication token found!")
        }
        
        networkService.request(endpoint, body: nil, completion: completion)
    }
    
    func getRepairerBooking(id: Int, completion: @escaping (Result<Booking, NetworkError>) -> Void) {
        networkService.request(APIEndpoint.getRepairerBooking(id: id), body: nil, completion: completion)
    }
    
    func updateRepairerBookingStatus(id: Int, status: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let requestDTO = UpdateRepairerBookingStatusDTO(booking: UpdateRepairerBookingStatusDTO.BookingStatus(status: status))
        networkService.request(APIEndpoint.updateRepairerBookingStatus(id: id, status: status), body: requestDTO, completion: completion)
    }
    
    func addRepairerBookingNote(id: Int, note: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let requestDTO = AddRepairerBookingNoteDTO(note: note)
        networkService.request(APIEndpoint.addRepairerBookingNote(id: id, note: note), body: requestDTO, completion: completion)
    }
}

// MARK: - DTOs

struct UpdateRepairerBookingStatusDTO: Codable {
    let booking: BookingStatus
    
    struct BookingStatus: Codable {
        let status: String
    }
}

struct AddRepairerBookingNoteDTO: Codable {
    let note: String
} 