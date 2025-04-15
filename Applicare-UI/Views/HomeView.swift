//
//  HomeView.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import SwiftUI

// Temporary Home View
struct HomeView: View {
    // Inject the AuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    // State to control presenting the settings sheet
    @State private var showSettings = false

    var body: some View {
        NavigationView { // Embed in NavigationView to enable navigation
            VStack(alignment: .leading, spacing: 20) { // Align content to leading
                HStack { // HStack for Welcome message and Settings Button
                    if let user = authViewModel.currentUser {
                        Text("Welcome, \(user.name)!")
                            .font(.largeTitle)
                    } else {
                        Text("Welcome!")
                            .font(.largeTitle)
                    }
                    Spacer()
                    // Settings Menu
                    Menu {
                        Button(action: {
                            showSettings = true
                        }) {
                            Label("Edit Profile", systemImage: "person.crop.circle")
                        }
                        
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Label("Logout", systemImage: "arrow.right.square")
                                .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                }

                if let user = authViewModel.currentUser {
                    // Display User Info if available
                    VStack(alignment: .leading) {
                        Text("Email: \(user.emailAddress)")
                        if let lat = user.latitude, let lon = user.longitude {
                             Text(String(format: "Location: %.4f, %.4f", lat, lon))
                        }
                        if let address = user.address, !address.isEmpty {
                            Text("Address: \(address)")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                } else {
                    // Fallback if user data isn't loaded yet
                    Text("Loading user data...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                // NavigationLink to the NearbyRepairersView
                NavigationLink(destination: NearbyRepairersView()) {
                    Text("Find Nearby Repairers")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer() // Pushes content to the top

                // Logout Button (Optional but good for testing)
                 // Logout button is now inside ProfileSettingsView
            }
            .padding() // Add padding to the VStack content
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // Optionally trigger profile fetch again if view appears and user is missing
            if authViewModel.isAuthenticated && authViewModel.currentUser == nil {
                authViewModel.fetchProfileData()
            }
        }
        .sheet(isPresented: $showSettings) {
            // Present ProfileSettingsView modally
            ProfileSettingsView()
                .environmentObject(authViewModel)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy AuthViewModel for the preview
        let previewAuthViewModel = AuthViewModel()
        // Optionally set a dummy user for previewing the logged-in state
        previewAuthViewModel.currentUser = User(
            id: 1, 
            name: "Preview User", 
            emailAddress: "preview@example.com", 
            address: "123 Preview St", 
            latitude: 10.0, 
            longitude: 106.0, 
            dateOfBirth: "1990-01-01",
            mobileNumber: "+1234567890",
            onboarded: true,
            createdAt: "", 
            updatedAt: ""
        )
        previewAuthViewModel.isAuthenticated = true

        return HomeView()
            .environmentObject(previewAuthViewModel)
    }
} 