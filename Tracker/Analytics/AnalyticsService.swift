import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    func reportWishToCreateTracker()
    func reportTrackerDeletion()
}

final class AnalyticsService: AnalyticsServiceProtocol {
    func reportWishToCreateTracker() {
        let params : [AnyHashable : Any] = ["add_count": 1]
        YMMYandexMetrica.reportEvent("tap_add_tracker", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportTrackerDeletion() {
        let params : [AnyHashable : Any] = ["delete_count": 1]
        YMMYandexMetrica.reportEvent("delete_tracker", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
