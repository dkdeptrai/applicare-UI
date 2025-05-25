//
//  Applicare_UIApp.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 9/3/25.
//

import SwiftUI

@main
struct Applicare_UIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Initialize view models with DI
    @StateObject private var authViewModel = AuthViewModel(
        authService: AuthNetworkService.shared,
        userService: UserNetworkService.shared
    )
    @StateObject private var repairerAuthViewModel = RepairerAuthViewModel(
        authService: AuthNetworkService.shared
    )
    
    // Add state to manage showing sign up screen and user type
    @State private var showSignUpScreen = false
    @State private var isRepairerMode = false
    
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
                // Show OnboardingView if user needs to complete onboarding
                if authViewModel.needsOnboarding {
                    OnboardingView()
                        .environmentObject(authViewModel)
                } else {
                    // Otherwise show the main Home view
                    HomeView()
                        .environmentObject(authViewModel)
                }
            } else if repairerAuthViewModel.isAuthenticated {
                // Show repairer home view if repairer is authenticated
                RepairerHomeView()
                    .environmentObject(repairerAuthViewModel)
            } else {
                // Container for Sign In / Sign Up flow
                AuthContainerView(
                    showSignUpScreen: $showSignUpScreen,
                    isRepairerMode: $isRepairerMode
                )
                .environmentObject(authViewModel)
                .environmentObject(repairerAuthViewModel)
            }
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
        return true
    }
}

// New Container View to handle showing SignIn or SignUp
struct AuthContainerView: View {
    @Binding var showSignUpScreen: Bool
    @Binding var isRepairerMode: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                // User type selector
                Picker("User Type", selection: $isRepairerMode) {
                    Text("Customer").tag(false)
                    Text("Repairer").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if showSignUpScreen {
                    if isRepairerMode {
                        RepairerSignUpView(showSignIn: $showSignUpScreen)
                    } else {
                        SignUpView(showSignIn: $showSignUpScreen)
                    }
                } else {
                    if isRepairerMode {
                        RepairerSignInView(showSignUp: $showSignUpScreen)
                    } else {
                        SignInView(showSignUp: $showSignUpScreen)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
