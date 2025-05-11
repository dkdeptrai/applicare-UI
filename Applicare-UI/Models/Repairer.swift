import Foundation // Import Foundation for Codable, Double, etc.

// Based on swagger components/schemas/repairer
// Added placeholder fields for UI elements not directly in the base schema (like rating, experience, isProfessional, title)
struct Repairer: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let email_address: String
    let hourly_rate: Double
    let service_radius: Int
    let latitude: Double?
    let longitude: Double?
    let created_at: String
    let updated_at: String

    // Placeholder fields for UI - these would ideally come from the API or be derived
    var title: String = "Appliance Repairer" // Default value
    var distanceKm: Double = 5.0 // Placeholder, should be calculated
    var rating: Double = 4.6 // Placeholder
    var yearsExperience: Int = 3 // Placeholder
    var isProfessional: Bool = true // Placeholder
    var imageName: String? = nil // Placeholder for image

    // Adjust CodingKeys if your JSON keys differ from struct properties
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email_address
        case hourly_rate
        case service_radius
        case latitude
        case longitude
        case created_at
        case updated_at
        // Placeholders are not typically part of API coding keys unless they come from the API
        // case title, distanceKm, rating, yearsExperience, isProfessional, imageName
    }

    // Add hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Repairer, rhs: Repairer) -> Bool {
        lhs.id == rhs.id
    }

    // Dummy data for previews and testing
    static let dummyRepairers: [Repairer] = [
        Repairer(id: 1, name: "John Doe", email_address: "john.doe@example.com", hourly_rate: 50.0, service_radius: 10, latitude: 34.0522, longitude: -118.2437, created_at: "2024-04-01T12:00:00", updated_at: "2024-04-01T12:00:00", title: "Appliance Repairer", distanceKm: 5.0, rating: 4.6, yearsExperience: 3, isProfessional: true, imageName: nil),
        Repairer(id: 2, name: "Jane Smith", email_address: "jane.smith@example.com", hourly_rate: 55.0, service_radius: 15, latitude: 34.0525, longitude: -118.2440, created_at: "2024-04-01T12:00:00", updated_at: "2024-04-01T12:00:00", title: "Plumber", distanceKm: 5.2, rating: 4.8, yearsExperience: 5, isProfessional: true, imageName: nil),
        Repairer(id: 3, name: "Robert Johnson", email_address: "robert.j@example.com", hourly_rate: 45.0, service_radius: 8, latitude: 34.0519, longitude: -118.2435, created_at: "2024-04-01T12:00:00", updated_at: "2024-04-01T12:00:00", title: "Electrician", distanceKm: 4.8, rating: 4.5, yearsExperience: 2, isProfessional: false, imageName: nil),
         Repairer(id: 4, name: "Maria Garcia", email_address: "maria.g@example.com", hourly_rate: 60.0, service_radius: 20, latitude: 34.0530, longitude: -118.2450, created_at: "2024-04-01T12:00:00", updated_at: "2024-04-01T12:00:00", title: "HVAC Technician", distanceKm: 6.1, rating: 4.7, yearsExperience: 4, isProfessional: true, imageName: nil)
    ]

     static let singleDummy = dummyRepairers[0] // For single repairer previews
}

struct RepairerResponseDTO: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
    let repairer: Repairer
} 