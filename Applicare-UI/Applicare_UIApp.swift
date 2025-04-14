//
//  Applicare_UIApp.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 9/3/25.
//

import SwiftUI

@main
struct Applicare_UIApp: App {
    // Initialize view models with DI
    @StateObject private var authViewModel = AuthViewModel(
        authService: AuthNetworkService.shared,
        userService: UserNetworkService.shared
    )
    
    @State private var isOnboardingComplete = OnboardingViewModel.hasCompletedOnboarding()
    // Add state to manage showing sign up screen
    @State private var showSignUpScreen = false
    
    init() {
        // Configure general appearance
        configureAppearance()
        
        // Log app startup
        print("Application started with base URL: \(APIEndpoint.baseURL)")
    }
    
    var body: some Scene {
        WindowGroup {
            // Use a container view to manage Auth state and Sign In/Sign Up toggle
            if authViewModel.isAuthenticated {
                 HomeView()
                     .environmentObject(authViewModel)
             } else {
                 // Container for Sign In / Sign Up flow
                 AuthContainerView(showSignUpScreen: $showSignUpScreen)
                     .environmentObject(authViewModel)
             }
            
            /* // Temporarily bypass onboarding and content view to show HomeView directly
            HomeView()
                // Inject authViewModel into the environment for HomeView and its children
                .environmentObject(authViewModel)
            */

            /* Original logic:
            if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            } else {
                ContentView()
                    .environmentObject(authViewModel)
            }
             */
        }
    }
    
    // Configure global UI appearance
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Use this appearance when a navigation bar appears
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// New Container View to handle showing SignIn or SignUp
struct AuthContainerView: View {
    @Binding var showSignUpScreen: Bool
    
    var body: some View {
        NavigationView { // Add NavigationView here to allow potential navigation within auth flow
             if showSignUpScreen {
                 SignUpView(showSignIn: $showSignUpScreen) // Pass binding to toggle back
             } else {
                 SignInView(showSignUp: $showSignUpScreen) // Pass binding to toggle
             }
        }
        .navigationViewStyle(.stack) // Use stack style
    }
}
