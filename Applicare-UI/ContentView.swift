//
//  ContentView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 9/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView()
                } else if showingSignUp {
                    SignUpView(showSignIn: $showingSignUp)
                } else {
                    SignInView(showSignUp: $showingSignUp)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
