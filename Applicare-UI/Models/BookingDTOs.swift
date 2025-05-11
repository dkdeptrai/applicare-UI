//
//  BookingDTOs.swift
//  Applicare-UI
//

import Foundation

// MARK: - Create Booking
struct CreateBookingRequestDTO: Codable {
    let booking: BookingData
    
    struct BookingData: Codable {
        let repairer_id: Int
        let service_id: Int
        let start_time: String // Expecting ISO 8601 format string
        let address: String
        let notes: String?
    }
}

// MARK: - Update Booking
struct UpdateBookingRequestDTO: Codable {
    let booking: BookingUpdateData
    
    struct BookingUpdateData: Codable {
        let address: String?
        let notes: String?
    }
} 