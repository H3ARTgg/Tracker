@testable import Tracker
import XCTest
import SnapshotTesting

class ScreenShotsTests: XCTestCase {
    func testTrackersViewController() throws {
        let trackersVC = TrackersViewController()
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
        trackersVC.viewModel = trackersViewModel
        
        assertSnapshot(matching: trackersVC, as: .image(precision: .nan, traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(matching: trackersVC, as: .image(precision: .nan, traits: .init(userInterfaceStyle: .dark)))
    }
}
