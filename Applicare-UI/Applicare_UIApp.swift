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
    
    init() {
        // Configure general appearance
        configureAppearance()
        
        // Log app startup
        print("Application started with base URL: \(APIEndpoint.baseURL)")
    }
    
    var body: some Scene {
        WindowGroup {
            // Temporarily bypass onboarding and content view to show HomeView directly
            HomeView()
                // Inject authViewModel if HomeView or subsequent views need it
                // .environmentObject(authViewModel)

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
