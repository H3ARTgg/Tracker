import Foundation

final class Storage {
    static let shared = Storage()
    static let onboardCompleteKey = "onboardComplete"
    
    static func isOnboardingCompleted() -> Bool {
        if UserDefaults.standard.object(forKey: onboardCompleteKey) != nil {
            return true
        } else {
            return false
        }
    }
    
    static func removeOnboardingCompletion() {
        UserDefaults.standard.removeObject(forKey: onboardCompleteKey)
    }
    
    static func addOnboardingCompletion() {
        UserDefaults.standard.set(1, forKey: onboardCompleteKey)
    }
}
