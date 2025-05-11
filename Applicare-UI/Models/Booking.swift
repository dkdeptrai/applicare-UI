//
//  Booking.swift
//  Applicare-UI
//
//

import Foundation

struct Booking: Codable, Identifiable {
    let id: Int
    let repairer_id: Int
    let service_id: Int
    let user_id: Int?  // Changed from customer_id to user_id to match API
    let start_time: String 
    let end_time: String
    let status: String
    let address: String
    let notes: String?     // Customer notes
    let repairer_note: String? // Repairer's notes
    let created_at: String
    let updated_at: String
    
    // Optional nested objects
    let user: User?
    let repairer: Repairer?
    let service: Service?
    
    // Helper computed property to maintain backward compatibility
    var customer_id: Int? {
        return user_id
    }
    
    // Helper method to get customer name directly
    var customerName: String {
        if let user = user {
            return user.name
        }
        
        return "Customer #\(user_id ?? 0)"
    }
    
    // Create a sample booking for previews
    static func sampleBooking(id: Int = 1, 
                             repairer_id: Int = 123, 
                             service_id: Int = 456, 
                             user_id: Int = 789, 
                             status: String = "confirmed", 
                             notes: String? = "Please bring tools for a leaky faucet repair",
                             repairer_note: String? = nil) -> Booking {
        return Booking(
            id: id,
            repairer_id: repairer_id,
            service_id: service_id,
            user_id: user_id,
            start_time: "2023-12-20T08:00:00.000Z",
            end_time: "2023-12-20T10:00:00.000Z",
            status: status,
            address: "123 Main St",
            notes: notes,
            repairer_note: repairer_note,
            created_at: "2023-12-15T09:30:00.000Z",
            updated_at: "2023-12-15T09:30:00.000Z",
            user: nil,
            repairer: nil,
            service: nil
        )
    }
}

// Simple model for nested Service object
struct Service: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let duration_minutes: Int?
    let base_price: String?
    let created_at: String?
    let updated_at: String?
} 