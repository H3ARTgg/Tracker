import Foundation

final class TabBarViewModel {
    /// Возвращает ViewModel для TrackersViewController
    func getViewModelForTrackers() -> TrackersViewModel {
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerStore = TrackerStore(trackerCategoryStore: trackerCategoryStore)
        let trackerRecordStore = TrackerRecordStore()
        let weekDayStore = WeekDayStore()
        let analyticsService = AnalyticsService()
        let trackersViewModel = TrackersViewModel(
            date: Date(),
            trackerCategoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            weekDayStore: weekDayStore,
            analyticsService: analyticsService
        )
        return trackersViewModel
    }
}
