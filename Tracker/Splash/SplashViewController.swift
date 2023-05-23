import UIKit

final class SplashViewController: UIViewController {
    private let window = UIApplication.shared.windows.first
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Storage.isOnboardingCompleted() {
            dismiss(animated: false) { [weak self] in
                self?.showTabBar()
            }
        } else {
            dismiss(animated: false) { [weak self] in
                self?.showOnboarding()
            }
        }
    }
    
    private func showTabBar() {
        let tabBar = TabBarController(nibName: .none, bundle: .main)
        window?.rootViewController = tabBar
    }
    
    private func showOnboarding() {
        let onboarding = OnboardingViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        window?.rootViewController = onboarding
    }
}
