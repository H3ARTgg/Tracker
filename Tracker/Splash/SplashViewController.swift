import UIKit

final class SplashViewController: UIViewController {
    private let window = UIApplication.shared.windows.first
    private var viewModel: SplashViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypBlue
        
        viewModel?.$isCompleted.bind(action: { [weak self] in
            if $0 {
                self?.dismiss(animated: false) {
                    self?.showTabBar()
                }
            } else {
                self?.dismiss(animated: false) {
                    self?.showOnboarding()
                }
            }
        })
        viewModel?.checkForCompletion()
    }
    
    required init(viewModel: SplashViewModel) {
        super.init(nibName: .none, bundle: .main)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Показать TabBarController
    private func showTabBar() {
        let tabBar = TabBarController(nibName: .none, bundle: .main)
        tabBar.viewModel = viewModel?.getViewModelForTabBar()
        window?.rootViewController = tabBar
    }
    
    /// Показать OnboardingViewController
    private func showOnboarding() {
        let onboarding = OnboardingViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        onboarding.viewModel = viewModel?.getViewModelForOnboarding()
        window?.rootViewController = onboarding
    }
}

