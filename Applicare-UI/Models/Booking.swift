//
//  Booking.swift
//  Applicare-UI
//
//  Created by Applicare on 19/6/24.
//

import Foundation

struct Booking: Codable, Identifiable {
    let id: Int
    let repairer_id: Int
    let service_id: Int
    let start_time: String // Consider converting to Date later if needed
    let end_time: String   // Consider converting to Date later if needed
    let status: String
    let address: String
    let notes: String?
    let created_at: String // Consider converting to Date later if needed
    let updated_at: String // Consider converting to Date later if needed
} 