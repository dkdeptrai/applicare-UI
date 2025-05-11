import SwiftUI

// REMOVE Mock Data Structures

// MARK: - Mock Data Instance (Temporary for Profile Details)
// Use the actual Repairer model, but add temporary mock data for fields not yet in the model
let mockRepairerBase = Repairer.singleDummy // Use one of the dummy repairers from the model

// Temporary mock data for fields MISSING from the Repairer model
let mockAboutMe = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
let mockWorkingHours: [String: String] = [
    "Monday": "8:00 - 20:00",
    "Tuesday": "8:00 - 20:00",
    "Wednesday": "8:00 - 20:00",
    "Thursday": "8:00 - 20:00",
    "Friday": "8:00 - 20:00",
    "Saturday": "8:00 - 12:00",
    "Sunday": "8:00 - 12:00"
]
let mockImages: [String] = ["image_placeholder_1", "image_placeholder_2", "image_placeholder_3"] // Placeholder URLs/names

// Temporary Review Struct and Data (Define it here until a real model exists)
struct TempReview: Identifiable { // Make it Identifiable for ForEach
    let id = UUID()
    let reviewerName: String
    let reviewerImage: String // Placeholder for image name/URL
    let rating: Int // 0-5 stars
    let comment: String
    let commentImages: [String] // Placeholder for image names/URLs
    let likes: Int
    let dislikes: Int
}

let mockReviews: [TempReview] = [
    TempReview(reviewerName: "Mary Jones", reviewerImage: "reviewer_placeholder_1", rating: 5, comment: "Excellent! Good expertise. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", commentImages: ["comment_image_1", "comment_image_2"], likes: 10, dislikes: 0),
    TempReview(reviewerName: "John Smith", reviewerImage: "reviewer_placeholder_2", rating: 4, comment: "Kindly and very generous! Lorem ipsum dolor sit amet, consectetur adipiscing elit.", commentImages: [], likes: 8, dislikes: 1),
    TempReview(reviewerName: "Mary Jones", reviewerImage: "reviewer_placeholder_1", rating: 5, comment: "Excellent! Good expertise. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", commentImages: ["comment_image_1", "comment_image_2"], likes: 10, dislikes: 0), // Duplicate for demo
]


// MARK: - Repairer Profile View

struct RepairerProfileView: View {
    // Parameter to pass in the specific repairer
    var repairer: Repairer
    
    // In a real app, you'd fetch the full Repairer details by ID
    var repairerBase: Repairer { repairer }
    // Use temporary mock data for detailed fields
    let aboutMe = mockAboutMe
    let workingHours = mockWorkingHours
    let images = mockImages
    let reviews = mockReviews

    // Environment variable to dismiss the view (if presented modally or in NavigationStack)
    @Environment(\.dismiss) var dismiss
    
    // Add initializer with default value
    init(repairer: Repairer = mockRepairerBase) {
        self.repairer = repairer
    }

    var body: some View {
        // Remove the NavigationView wrapper
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                HeaderView(repairer: repairerBase) // Pass the base Repairer object

                // Stats Section
                StatsView(repairer: repairerBase, reviewCount: reviews.count) // Pass base Repairer and review count

                // About Me Section
                AboutMeView(aboutText: aboutMe) // Pass temporary mock data

                // Working Hours Section
                WorkingHoursView(hours: workingHours) // Pass temporary mock data

                // Images Section
                ImagesView(imageNames: images) // Pass temporary mock data

                // Reviews Section
                ReviewsView(reviews: reviews) // Pass temporary mock data

                Spacer() // Push content up
            }
            .padding(.horizontal) // Add horizontal padding to the main VStack
        }
        // Navigation bar configuration stays
        .navigationTitle("Repairer details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Action for share button
                    print("Share tapped")
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
            }
        }
        // Bottom Buttons - overlay or place outside ScrollView depending on desired behavior
        .safeAreaInset(edge: .bottom) {
            BottomButtonsView(repairer: repairer)
                .background(.thinMaterial) // Add background for visibility
        }
        // Use .navigationViewStyle(.stack) if needed for specific navigation behavior
    }
}

// MARK: - Subviews

struct HeaderView: View {
    let repairer: Repairer // Use the actual Repairer model

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Profile Image Placeholder - Use repairer.imageName if available
            Image(systemName: repairer.imageName ?? "person.crop.circle.fill") // Use placeholder if imageName is nil
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .foregroundColor(.gray)
             // Consider using AsyncImage for real URLs when imageName is available

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(repairer.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if repairer.isProfessional { // Use the field from the actual model
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Professional")
                        }
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                }
                Text(repairer.title) // Use 'title' from the actual model
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                    // Safely unwrap latitude and longitude
                    if let latitude = repairer.latitude, let longitude = repairer.longitude {
                        Text("Location: \(String(format: "%.2f", latitude)), \(String(format: "%.2f", longitude))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Location not available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            Spacer() // Push content to the left
        }
    }
}

struct StatsView: View {
    let repairer: Repairer // Use the actual Repairer model
    let reviewCount: Int // Pass review count separately

    var body: some View {
        HStack(spacing: 10) { // Adjust spacing as needed
             Spacer() // Add spacers to distribute evenly
             // Placeholder for Clients count - add to Repairer model if needed
             StatBubble(value: "500+", label: "Clients", icon: "person.3.fill") // Using different icon as client count isn't in model
             Spacer()
             StatBubble(value: "\(repairer.yearsExperience) years+", label: "Exp", icon: "clock.fill") // Use yearsExperience, changed icon
             Spacer()
             StatBubble(value: String(format: "%.1f", repairer.rating), label: "Ratings", icon: "star.fill") // Use rating from model
             Spacer()
             StatBubble(value: "\(reviewCount)", label: "Reviews", icon: "message.fill") // Use passed reviewCount
             Spacer()
         }
        .padding(.vertical)
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    let icon: String // System name for the icon

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                 .font(.title3) // Adjusted size
                 .frame(width: 40, height: 40) // Fixed size circle
                 .background(Color.blue.opacity(0.1))
                 .foregroundColor(.blue)
                 .clipShape(Circle())

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 70) // Give each bubble a fixed width
    }
}

struct AboutMeView: View {
    let aboutText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About me")
                .font(.title3)
                .fontWeight(.semibold)
            Text(aboutText) // Use passed mock data
                .font(.body)
                .foregroundColor(.secondary) // Lighter text color
        }
    }
}

struct WorkingHoursView: View {
    let hours: [String: String]
    // Ensure order if necessary, Dictionary iteration order isn't guaranteed
    let daysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Working hours")
                .font(.title3)
                .fontWeight(.semibold)
            ForEach(daysOrder, id: \.self) { day in // Fixed key path syntax
                 if let time = hours[day] {
                     HStack {
                         Text(day)
                             .frame(width: 100, alignment: .leading) // Align days
                             .foregroundColor(.gray)
                         Spacer()
                         Text(time)
                              .foregroundColor(.gray)
                     }
                     .font(.subheadline)
                 }
             }
        }
    }
}

struct ImagesView: View {
    let imageNames: [String] // Placeholder names/URLs

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Images")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("See more") {
                    // Action for See more images
                    print("See more images tapped")
                }
                .font(.subheadline)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(imageNames, id: \.self) { imageName in // Fixed key path syntax
                        // Placeholder Image
                        Image(systemName: "photo") // Placeholder icon
                            .resizable()
                            .scaledToFill() // Use fill to mimic image behavior
                            .frame(width: 120, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            .foregroundColor(.gray)

                        // Use actual image loading here when available
                        // Example: AsyncImage(url: URL(string: imageName)) { phase ... }
                    }
                }
            }
        }
    }
}

struct ReviewsView: View {
    let reviews: [TempReview] // Use the temporary Review struct

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                 Text("Reviews")
                     .font(.title3)
                     .fontWeight(.semibold)
                 Spacer()
                 Button("See more") {
                     // Action for See more reviews
                     print("See more reviews tapped")
                 }
                 .font(.subheadline)
            }
            .padding(.bottom, 5)

            // Display only the first few reviews, for example
            ForEach(reviews.prefix(2)) { review in // Use TempReview which is Identifiable
                ReviewRow(review: review)
                Divider() // Add separator between reviews
            }
        }
    }
}

struct ReviewRow: View {
    let review: TempReview // Use the temporary Review struct

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Reviewer Image Placeholder
                Image(systemName: "person.crop.circle.fill") // Placeholder
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
                // Or: Image(review.reviewerImage)...

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.headline)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in // Already correct, using Range<Int>
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption) // Smaller stars
                        }
                    }
                }
                Spacer() // Push likes/dislikes to the right
                HStack(spacing: 15) {
                     Label("\(review.likes)", systemImage: "hand.thumbsup.fill")
                     Label("\(review.dislikes)", systemImage: "hand.thumbsdown.fill")
                 }
                 .font(.subheadline)
                 .foregroundColor(.gray)
            }

            Text(review.comment)
                 .font(.body)
                 .foregroundColor(.secondary) // Slightly lighter text

            // Optional: Display comment images
             if !review.commentImages.isEmpty {
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         ForEach(review.commentImages, id: \.self) { img in // Fixed key path syntax
                             Image(systemName: "photo") // Placeholder
                                 .resizable()
                                 .scaledToFill()
                                 .frame(width: 60, height: 60)
                                 .background(Color.gray.opacity(0.2))
                                 .cornerRadius(4)
                                 .foregroundColor(.gray)
                         }
                     }
                 }
                 .frame(height: 65) // Set fixed height for the scroll view
             }
        }
        .padding(.vertical, 8) // Add padding around each review row
    }
}

struct BottomButtonsView: View {
    // Add properties for a mock booking
    let repairer: Repairer
    
    // Mock booking for demonstration purposes
    private var mockBooking: Booking {
        Booking.sampleBooking(
            repairer_id: repairer.id,
            status: "pending",
            notes: nil,
            repairer_note: nil
        )
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Replace the Message button with ChatButton
            ChatButton(booking: mockBooking, contactName: repairer.name)
                .frame(maxWidth: .infinity)

            Button {
                 // Book Now Action
                 print("Book now tapped")
             } label: {
                 Text("Book now")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.blue) // Primary action color
                     .foregroundColor(.white)
                     .cornerRadius(10)
                     .fontWeight(.semibold)
             }
        }
        .padding(.horizontal) // Add padding to the HStack itself
        .padding(.vertical, 10) // Add vertical padding for spacing from content/bottom edge
    }
}


// MARK: - Preview

struct RepairerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RepairerProfileView()
    }
} 