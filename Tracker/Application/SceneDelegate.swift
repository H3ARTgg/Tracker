import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        if UserDefaults.standard.object(forKey: Constants.onboardCompleteKey) != nil {
            window?.rootViewController = TabBarController(nibName: .none, bundle: .main)
        } else {
            window?.rootViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        }
        window?.makeKeyAndVisible()
    }
}

