import Foundation

struct OnboardingState {
    static let key = "hasCompletedOnboarding"
    
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
} 