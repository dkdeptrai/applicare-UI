//
//  BookingNetworkService.swift
//  Applicare-UI
//
//  Created by Applicare on 19/6/24.
//

import Foundation

protocol BookingNetworkServiceProtocol {
    func getAllBookings(completion: @escaping (Result<[Booking], NetworkError>) -> Void)
    func createBooking(request: CreateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 201 returns no body
    func getBooking(id: Int, completion: @escaping (Result<Booking, NetworkError>) -> Void)
    func updateBooking(id: Int, request: UpdateBookingRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 200 returns no body
    func cancelBooking(id: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) // Assuming 204 returns no body
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
} 