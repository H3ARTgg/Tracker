import UIKit

final class TrackersViewModel: NewTrackerDelegate {
    private var currentDate: Date
    private let trackerCategoryStore: TrackerCategoryStoreProtocol!
    private let trackerStore: TrackerStoreProtocol!
    private let trackerRecordStore: TrackerRecordStoreProtocol!
    private let weekDayStore: WeekDayStoreProtocol!
    private(set) var stringCategories: [String] = []
    @Observable private(set) var trackersCategories: [TrackersSupplementaryViewModel] = []
    
    init(date: Date, trackerCategoryStore: TrackerCategoryStoreProtocol, trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStoreProtocol, weekDayStore: WeekDayStoreProtocol) {
        self.currentDate = date
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        self.weekDayStore = weekDayStore
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Возвращает массив TrackersCellViewModel для конкретной категории
    private func getTrackersCellViewModelsFor(_ category: CDTrackerCategory) -> [TrackersCellViewModel] {
        guard let trackers = trackerStore.trackers else { return [] }
        var sameCategoryTrackers: [TrackersCellViewModel] = []
        var rowNumber = 0
        
        for tracker in trackers {
            if tracker.category == category {
                rowNumber += 1
                let isRecordExists = trackerRecordStore
                    .isRecordExistsFor(
                        trackerID: tracker.id ?? UUID(),
                        and: currentDate
                    )
                let recordCount = trackerRecordStore
                    .recordsCountFor(trackerID: tracker.id ?? UUID())
                let trackersCellViewModelSample = TrackersCellViewModelSample(
                    id: tracker.id ?? UUID(),
                    color: ColorMarshalling.color(from: tracker.colorHex ?? ""),
                    name: tracker.name ?? "",
                    emoji: tracker.emoji ?? "",
                    recordCount: recordCount,
                    isRecordExists: isRecordExists,
                    currentDate: currentDate,
                    delegate: self,
                    rowNumber: rowNumber
                )
                sameCategoryTrackers.append(
                    TrackersCellViewModel(cellSample: trackersCellViewModelSample)
                )
            }
        }
        return sameCategoryTrackers
    }
    
    /// Возвращает массив TrackersSupplementaryViewModel
    private func getTrackersCategories() -> [TrackersSupplementaryViewModel] {
        var trackerCategories: [TrackersSupplementaryViewModel] = []
        let sections = trackerStore.getFetchedCategories()
        
        for section in sections {
            let sameCategoryTrackers = getTrackersCellViewModelsFor(section)
            
            let trackerCategory = TrackersSupplementaryViewModel(
                title: section.title ?? "",
                trackers: sameCategoryTrackers
            )
            trackerCategories.append(trackerCategory)
        }
        return trackerCategories.sorted { $0.title < $1.title }
    }
    
    /// Показывает трекеры для конкретной даты (и поиска)
    func showTrackersFor(date: Date, search: String) {
        self.currentDate = date
        try? trackerStore.fetchTrackersByDayOfTheWeekFor(date: currentDate, searchText: search)
        trackersCategories = getTrackersCategories()
        stringCategories = trackerCategoryStore.getAllCategoriesTitles()
    }
    
    /// Настройка ячейки для данного IndexPath
    func configure(_ cell: TrackersCell, for indexPath: IndexPath) {
        cell.viewModel = trackersCategories[indexPath.section].trackers[indexPath.row]
    }
    
    /// Возвращает ViewModel для NewTrackerViewController
    func getViewModelForNewTracker() -> NewTrackerViewModel {
        NewTrackerViewModel(delegate: self)
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
    func didRecieveTracker(_ tracker: Tracker, category: String, allCategories: [String]) throws {
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
        
        let categoriesWithoutSelected = allCategories.filter { $0 != category }
        for category in categoriesWithoutSelected {
            if !trackerCategoryStore.checkForExisting(categoryTitle: category) {
                let trackerCategory = TrackerCategory(title: category, trackers: [], createdAt: Date())
                trackerCategoryStore.addNewTrackerCategory(trackerCategory)
            }
        }
        showTrackersFor(date: currentDate, search: "")
    }
}
