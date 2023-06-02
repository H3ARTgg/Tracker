final class OnboardingViewModel {
    private let storage = Storage()
    
    func setOnboardingCompletion() {
        storage.addOnboardingCompletion()
    }
    
    func getViewModelForTabBar() -> TabBarViewModel {
        TabBarViewModel()
    }
}
