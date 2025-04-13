//
//  HomeView.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import SwiftUI

// Temporary Home View
struct HomeView: View {
    var body: some View {
        NavigationView { // Embed in NavigationView to enable navigation
            VStack {
                Text("Welcome!")
                    .font(.largeTitle)
                    .padding(.bottom, 40)

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
                .padding(.horizontal, 40)

                Spacer() // Pushes content to the top
            }
            .navigationTitle("Home") // Optional: Add a title
            .navigationBarHidden(true) // Hide the navigation bar for this specific view if desired
        }
        .navigationViewStyle(.stack) // Consistent navigation style
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 