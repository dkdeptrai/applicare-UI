//
//  UserViewModel.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import Foundation

class UserViewModel: ObservableObject {
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  
  private let userService: UserNetworkServiceProtocol
  
  init(userService: UserNetworkServiceProtocol = UserNetworkService.shared) {
    self.userService = userService
  }
}
