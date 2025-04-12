//
//  UserDTO.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

struct UserDTO: Codable {
    let id: Int
    let name: String
    let email_address: String
    let created_at: String
    let updated_at: String
} 