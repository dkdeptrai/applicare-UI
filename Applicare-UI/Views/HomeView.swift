//
//  HomeView.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let user = authViewModel.currentUser {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("You are logged in!")
                            .font(.headline)
                        
                        HStack {
                            Text("Email:")
                                .fontWeight(.semibold)
                            Text(user.emailAddress)
                        }
                        
                        HStack {
                            Text("Email Verified:")
                                .fontWeight(.semibold)
                            Text(user.isEmailVerified ? "Yes" : "No")
                                .foregroundColor(user.isEmailVerified ? .green : .red)
                        }
                        
                        HStack {
                            Text("User ID:")
                                .fontWeight(.semibold)
                            Text("\(user.id)")
                        }
                        
                        HStack {
                            Text("Account Created:")
                                .fontWeight(.semibold)
                            Text(formatDate(user.createdAt))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if !user.isEmailVerified {
                        Button(action: {
                            authViewModel.resendVerificationEmail()
                        }) {
                            Text("Verify Email")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(height: 45)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Home", displayMode: .large)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} 