import Foundation // Import Foundation for Codable, Double, etc.

// Based on swagger components/schemas/repairer
// Added placeholder fields for UI elements not directly in the base schema (like rating, experience, isProfessional, title)
struct Repairer: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let emailAddress: String? // Made optional as it might not be needed for list view
    let hourlyRate: Double?
    let serviceRadius: Int?
    let latitude: Double
    let longitude: Double

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
        case emailAddress = "email_address"
        case hourlyRate = "hourly_rate"
        case serviceRadius = "service_radius"
        case latitude
        case longitude
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
        Repairer(id: 1, name: "John Doe", emailAddress: "john.doe@example.com", hourlyRate: 50.0, serviceRadius: 10, latitude: 34.0522, longitude: -118.2437, title: "Appliance Repairer", distanceKm: 5.0, rating: 4.6, yearsExperience: 3, isProfessional: true, imageName: nil),
        Repairer(id: 2, name: "Jane Smith", emailAddress: "jane.smith@example.com", hourlyRate: 55.0, serviceRadius: 15, latitude: 34.0525, longitude: -118.2440, title: "Plumber", distanceKm: 5.2, rating: 4.8, yearsExperience: 5, isProfessional: true, imageName: nil),
        Repairer(id: 3, name: "Robert Johnson", emailAddress: "robert.j@example.com", hourlyRate: 45.0, serviceRadius: 8, latitude: 34.0519, longitude: -118.2435, title: "Electrician", distanceKm: 4.8, rating: 4.5, yearsExperience: 2, isProfessional: false, imageName: nil),
         Repairer(id: 4, name: "Maria Garcia", emailAddress: "maria.g@example.com", hourlyRate: 60.0, serviceRadius: 20, latitude: 34.0530, longitude: -118.2450, title: "HVAC Technician", distanceKm: 6.1, rating: 4.7, yearsExperience: 4, isProfessional: true, imageName: nil)
    ]

     static let singleDummy = dummyRepairers[0] // For single repairer previews
} 