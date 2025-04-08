//
//  UserViewModel.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import Foundation

class UserViewModel: ObservableObject {
  @Published var users: [User] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  
  private let userService: UserNetworkServiceProtocol
  
  init(userService: UserNetworkServiceProtocol = UserNetworkService.shared) {
    self.userService = userService
  }
  
  func fetchUsers() {
    isLoading = true
    errorMessage = nil
    
    userService.getUsers { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        
        switch result {
        case .success(let userDTOs):
          self?.users = userDTOs.compactMap { User(from: $0) }
        case .failure(let error):
          self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
        }
      }
    }
  }
}
