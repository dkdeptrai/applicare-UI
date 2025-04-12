import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var isOnboardingComplete = false
    
    let pages = [
        OnboardingPage(
            title: "Diagnose your Appliances",
            description: "Something is acting up? No worries, explain the symptoms and we will have a diagnosis.",
            animationName: "Repair"
        ),
        OnboardingPage(
            title: "Fix your stuffs with ease",
            description: "Get the quality instructions you need and repair things on your own",
            animationName: "Electrician"
        ),
        OnboardingPage(
            title: "Connect to a Repairer",
            description: "When things get out of hand, book an appointment with a Repairer to solve your problem",
            animationName: "Plumber"
        )
    ]
    
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func completeOnboarding() {
        // Set flag in UserDefaults
        UserDefaults.standard.set(true, forKey: OnboardingViewModel.hasCompletedOnboardingKey)
        isOnboardingComplete = true
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let animationName: String
} 