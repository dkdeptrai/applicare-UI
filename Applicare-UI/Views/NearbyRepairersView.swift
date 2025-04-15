import SwiftUI

// View to display the list of nearby repairers
struct NearbyRepairersView: View {
    // In a real app, this would be populated by a ViewModel fetching from the API
    @State private var repairers: [Repairer] = Repairer.dummyRepairers
    @State private var selectedRepairer: Repairer? = nil // State to track navigation

    var body: some View {
        List {
            ForEach(repairers) { repairer in
                // Use ZStack to layer NavigationLink behind the row content
                ZStack {
                    // The actual row content
                    RepairerRow(repairer: repairer)

                    // Invisible NavigationLink covering the ZStack
                    NavigationLink(destination: RepairerBookingView(repairer: repairer)) {
                        EmptyView() // Content is provided by RepairerRow
                    }
                    .opacity(0) // Make the link invisible
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Repairers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RepairerRow: View {
    let repairer: Repairer

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                // Placeholder for Image
                RoundedRectangle(cornerRadius: 8)
                     .fill(Color.gray.opacity(0.2))
                     .frame(width: 70, height: 70)
                     .overlay(
                         Image(systemName: "person.crop.square") // Placeholder icon
                             .resizable()
                             .scaledToFit()
                             .scaleEffect(0.5)
                             .foregroundColor(.gray)
                     )


                VStack(alignment: .leading, spacing: 4) {
                     HStack {
                         if repairer.isProfessional {
                            ProfessionalBadge()
                         }
                         Spacer() // Pushes badge to the left if present
                     }

                    Text(repairer.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(repairer.title) // Using the placeholder title
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    HStack(spacing: 15) {
                        InfoItem(icon: "paperplane.fill", text: String(format: "%.1f km", repairer.distanceKm))
                        InfoItem(icon: "star.fill", text: String(format: "%.1f", repairer.rating), iconColor: .yellow)
                        InfoItem(icon: "gearshape.fill", text: "\(repairer.yearsExperience) years exp")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                }
            }

             Text("Book Now")
                 .font(.footnote)
                 .fontWeight(.semibold)
                 .frame(maxWidth: .infinity)
                 .padding(.vertical, 8)
                 .background(Color.blue.opacity(0.15))
                 .foregroundColor(.blue)
                 .cornerRadius(8)


        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InfoItem: View {
    let icon: String
    let text: String
    var iconColor: Color = .gray

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(text)
        }
    }
}

struct ProfessionalBadge: View {
    var body: some View {
         HStack(spacing: 4) {
             Image(systemName: "checkmark.seal.fill")
                 .font(.caption2)
             Text("Professional")
                 .font(.caption2)
                 .fontWeight(.medium)
         }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(10)
    }
}


// MARK: - Preview
struct NearbyRepairersView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyRepairersView()
    }
}

