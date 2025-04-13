//
//  User.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import Foundation

// Conforms to Codable for easy JSON decoding
// Matches the /api/v1/profile response structure
struct User: Codable, Identifiable {
    let id: Int
    let name: String // Added
    let emailAddress: String
    let address: String? // Added (marked optional as it can be empty)
    let latitude: Double? // Added (marked optional)
    let longitude: Double? // Added (marked optional)
    let createdAt: String // Keep as String for direct decoding
    let updatedAt: String // Keep as String for direct decoding

    // Define coding keys to map JSON keys to struct properties
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emailAddress = "email_address"
        case address
        case latitude
        case longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // You might want computed properties to get Date objects if needed
    var createdAtDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }

    var updatedAtDate: Date? {
        ISO8601DateFormatter().date(from: updatedAt)
    }
}

// Remove the old extension that used UserDTO
// extension User {
//    init?(from dto: UserDTO) {
//        ...
//    }
// }
  