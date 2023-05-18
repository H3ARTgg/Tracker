import UIKit

// Вот такая реализация. Не стал, пока что, делать все под MVVM, так как хочу увидеть фидбек по данной реализации, а затем уже, исправляя ошибки, переделывать все под MVVM.
final class TrackersViewModel: NewTrackerDelegate {
    private var currentDate: Date
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let uiColorMarshalling = UIColorMarshalling()
    private let weekDayStore = WeekDayStore()
    private(set) var stringCategories: [String] = []
    @Observable private(set) var trackersCategories: [TrackersSupplementaryViewModel] = []
    
    func showTrackersFor(date: Date, search: String) {
        self.currentDate = date
        try? trackerStore.fetchTrackersByDayOfTheWeekFor(date: currentDate, searchText: search)
        trackersCategories = getTrackersCategories()
        stringCategories = trackerCategoryStore.getAllCategoriesTitles()
    }
    
    init(date: Date) {
        self.currentDate = date
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Возвращает массив TrackersSupplementaryViewModel
    private func getTrackersCategories() -> [TrackersSupplementaryViewModel] {
        var trackerCategories: [TrackersSupplementaryViewModel] = []
        if let trackers = trackerStore.trackers {
            let sections = trackerStore.getFetchedCategories()
            for section in sections {
                var number = 0
                var sameCategoryTrackers: [TrackersCellViewModel] = []
                for tracker in trackers {
                    if tracker.category == section {
                        number += 1
                        let isRecordExists = trackerRecordStore
                            .isRecordExistsFor(
                            trackerID: tracker.id ?? UUID(),
                            and: currentDate
                        )
                        let recordCount = trackerRecordStore
                            .recordsCountFor(trackerID: tracker.id!)
                        sameCategoryTrackers.append(
                            TrackersCellViewModel(
                                id: tracker.id ?? UUID(),
                                color:
                                    uiColorMarshalling
                                    .color(from: tracker.colorHex ?? ""),
                                name: tracker.name ?? "",
                                emoji: tracker.emoji ?? "",
                                recordCount: recordCount,
                                isRecordExists: isRecordExists,
                                currentDate: currentDate,
                                delegate: self,
                                number: number
                            )
                        )
                    }
                }
                let trackerCategory = TrackersSupplementaryViewModel(
                    title: section.title ?? "",
                    trackers: sameCategoryTrackers
                )
                trackerCategories.append(trackerCategory)
            }
            return trackerCategories.sorted { $0.title < $1.title }
        }
        return []
    }
}

// MARK: - TrackersCellDelegate
extension TrackersViewModel: TrackersCellDelegate {
    func didRecieveNewRecord(_ completed: Bool, for id: UUID) {
        let newRecord = TrackerRecord(id: id, date: currentDate)
        if completed {
            let newRecord = TrackerRecord(id: id, date: currentDate)
            try? trackerRecordStore.addTrackerRecord(newRecord)
        } else {
            try? trackerRecordStore.deleteTrackerRecord(newRecord, for: currentDate)
        }
    }
}

// MARK: - HabitOrEventDelegate
extension TrackersViewModel: HabitOrEventDelegate {
    func didRecieveTracker(_ tracker: Tracker, forCategoryTitle category: String) throws {
        let newTrackerCategory = TrackerCategory(title: category, trackers: [tracker], createdAt: Date())
        
        let isTrackerExists = trackerStore.checkForExisting(tracker: tracker)
        if isTrackerExists {
            let existingTracker = try trackerStore.getCDTracker(tracker: tracker)
            let existingCategory = try trackerCategoryStore.getCDTrackerCategoryFor(title: category)
            trackerStore.updateExistingTracker(existingTracker, with: tracker, for: existingCategory)
        } else {
            let isCategoryExist = trackerCategoryStore.checkForExisting(categoryTitle: category)
            if isCategoryExist {
                try trackerStore.addNewTracker(tracker, forCategoryTitle: category)
            } else {
                trackerCategoryStore.addNewTrackerCategory(newTrackerCategory)
                try trackerStore.addNewTracker(tracker, forCategoryTitle: category)
            }
        }
        showTrackersFor(date: currentDate, search: "")
    }
}
