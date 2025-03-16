//
//  UserViewModel.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import Foundation

class UserViewModel: ObservableObject {
  @Published var users: [User] = []
  @Published var errorMessage: String?
  
  func fetchUsers() {
    NetworkService.shared.fetchData(from: "https://api.example.com/users") { (result: Result<[UserDTO], NetworkError>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let userDTOs):
          self.users = userDTOs.map { User(from: $0) }
        case .failure(let error):
          self.errorMessage = error.localizedDescription
        }
      }
    }
  }
}
