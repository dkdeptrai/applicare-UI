import Foundation

class ApplianceNetworkService {
    static let shared = ApplianceNetworkService()
    private init() {}
    
    func fetchMyAppliances(completion: @escaping (Result<[Appliance], Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/v1/appliances/my_appliances") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = AuthNetworkService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            do {
                let appliances = try JSONDecoder().decode([Appliance].self, from: data)
                completion(.success(appliances))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRepairHistoryForAppliance(applianceId: Int, completion: @escaping (Result<[Booking], Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:3000/api/v1/appliances/\(applianceId)/repair_history") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = AuthNetworkService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            do {
                let bookings = try JSONDecoder().decode([Booking].self, from: data)
                completion(.success(bookings))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
} 
