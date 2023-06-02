import Foundation

final class Storage {
    private let userDefaults = UserDefaults.standard
    let onboardCompleteKey = "onboardComplete"
    var isCompleted: Bool {
        get {
            userDefaults.bool(forKey: onboardCompleteKey)
        }
    }
    
    func removeOnboardingCompletion() {
        userDefaults.set(false, forKey: onboardCompleteKey)
    }
    
    func addOnboardingCompletion() {
        userDefaults.set(true, forKey: onboardCompleteKey)
    }
}
