import Foundation

struct Appliance: Codable, Identifiable {
    let id: Int
    let name: String
    let brand: String
    let model: String
    let image_url: String?
    let created_at: String
    let updated_at: String
} 