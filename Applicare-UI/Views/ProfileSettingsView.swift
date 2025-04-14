import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Remove state for edit sheet
    // @State private var showEditSheet = false

    var body: some View {
        NavigationView {
            Form { 
                Section(header: Text("Personal Information")) {
                    if let user = authViewModel.currentUser {
                        InfoRow(label: "Name", value: user.name)
                        InfoRow(label: "Email", value: user.emailAddress)
                        InfoRow(label: "Address", value: user.address ?? "Not set")
                        // TODO: Add Phone Number and DOB when available in User model
                        // InfoRow(label: "Phone", value: user.phoneNumber ?? "Not set")
                        // InfoRow(label: "Birthday", value: user.dateOfBirth?.formatted(date: .long, time: .omitted) ?? "Not set")
                    } else {
                        Text("Loading profile...")
                    }
                }
                
                Section {
                    // Remove Edit Button until API is available
                    // Button("Edit Information") {
                    //     showEditSheet = true
                    // }
                    Text("Profile editing coming soon!") // Placeholder text
                        .foregroundColor(.gray)
                    
                    Button("Logout", role: .destructive) {
                        authViewModel.logout()
                    }
                }
            }
            .navigationTitle("Settings")
            // Remove sheet modifier
            // .sheet(isPresented: $showEditSheet) { ... }
            .onAppear {
                // Ensure profile data is fresh when view appears
                if authViewModel.currentUser == nil {
                    authViewModel.fetchProfileData()
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthViewModel()
        authVM.currentUser = User(id: 1, name: "Jane Doe", emailAddress: "jane@example.com", address: "456 Oak Ave", latitude: 11.0, longitude: 107.0, createdAt: "", updatedAt: "")
        authVM.isAuthenticated = true
        
        return ProfileSettingsView()
            .environmentObject(authVM)
    }
} 