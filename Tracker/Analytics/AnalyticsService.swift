import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    func report(event: Event, screen: Screen, item: Item?)
}

enum Event: String {
    case open, close, click
}

enum Screen: String {
    case trackersList = "trackers_list"
}

enum Item: String {
    case addTracker = "add_tracker"
    case doneTracker = "done_tracker"
    case filter, edit, delete
}

final class AnalyticsService: AnalyticsServiceProtocol {
    func report(event: Event, screen: Screen, item: Item?) {
        var params: [AnyHashable: Any] = ["screen": screen.rawValue]
        if event == .click, let item {
            params["item"] = item.rawValue
        }

        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
