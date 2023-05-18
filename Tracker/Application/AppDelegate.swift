import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("No persistent store")
            }
        }
        return container
    }()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    func recreatePersistentContainer() {
        // Delete each existing persistent store
        for store in persistentContainer.persistentStoreCoordinator.persistentStores {
            try? persistentContainer.persistentStoreCoordinator.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }

        // Re-create the persistent container
        persistentContainer = NSPersistentContainer(
            name: "Model"
        )

        // Calling loadPersistentStores will re-create the
        // persistent stores
        persistentContainer.loadPersistentStores { _,_  in }
    }
}

