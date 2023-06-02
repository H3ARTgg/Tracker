final class SplashViewModel {
    private let storage = Storage()
    @Observable private(set) var isCompleted: Bool = false
    
    /// Проверяет выполненность онбоардинга
    func checkForCompletion() {
        isCompleted = storage.isCompleted
    }
    
    /// Возвращает ViewModel для TabBarController
    func getViewModelForTabBar() -> TabBarViewModel {
        TabBarViewModel()
    }
    
    /// Возвращает ViewModel для OnboardingViewController
    func getViewModelForOnboarding() -> OnboardingViewModel {
        OnboardingViewModel()
    }
}
