//
//  User.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import Foundation

struct User {
    let id: Int
    let emailAddress: String
    let createdAt: Date
    let updatedAt: Date
}

extension User {
    init?(from dto: UserDTO) {
        self.id = dto.id
        self.emailAddress = dto.email_address
        
        let dateFormatter = ISO8601DateFormatter()
        
        guard let createdAt = dateFormatter.date(from: dto.created_at),
              let updatedAt = dateFormatter.date(from: dto.updated_at) else {
            return nil
        }
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
  