//
//  NetworkError.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import Foundation

enum NetworkError: Error {
  case invalidURL
  case requestFailed
  case decodingFailed
}

class NetworkService {
  static let shared = NetworkService()
  
  private init() {}
  
  func fetchData<T: Decodable>(from urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
    guard let url = URL(string: urlString) else {
      completion(.failure(.invalidURL))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      if error != nil {
        completion(.failure(.requestFailed))
        return
      }
      
      guard let data = data else {
        completion(.failure(.requestFailed))
        return
      }
      
      do {
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        completion(.success(decodedData))
      } catch {
        completion(.failure(.decodingFailed))
      }
    }.resume()
  }
}
