//
//  User.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import Foundation

struct User {
    let id: Int
    let name: String
    let email: String
}

extension User {
  init(from dto: UserDTO) {
    self.id = dto.id
    self.name = dto.name
    self.email = dto.email
  }
}
  