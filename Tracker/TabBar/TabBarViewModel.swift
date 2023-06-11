import Foundation

final class TabBarViewModel {
    /// Возвращает ViewModels для TrackersViewController и StatisticViewController
    func getViewModels() -> (TrackersViewModel, StatisticViewModel) {
        let trackerRecordStore = TrackerRecordStore()
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerStore = TrackerStore(trackerCategoryStore: trackerCategoryStore)
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
        
        let statisticViewModel = StatisticViewModel(statisticRecords: trackerRecordStore)
        trackersViewModel.delegate = statisticViewModel
        return (trackersViewModel, statisticViewModel)
    }
}
