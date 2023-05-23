import UIKit

// Вот такая реализация. Не стал, пока что, делать все под MVVM, так как хочу увидеть фидбек по данной реализации, а затем уже, исправляя ошибки, переделывать все под MVVM.
final class TrackersViewModel: NewTrackerDelegate {
    private var currentDate: Date
    private let trackerCategoryStore: TrackerCategoryStoreProtocol!
    private let trackerStore: TrackerStore
    private let trackerRecordStore = TrackerRecordStore()
    private let weekDayStore = WeekDayStore()
    private(set) var stringCategories: [String] = []
    @Observable private(set) var trackersCategories: [TrackersSupplementaryViewModel] = []
    
    init(date: Date, trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.currentDate = date
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = TrackerStore(trackerCategoryStore: trackerCategoryStore)
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
                sameCategoryTrackers.append(
                    TrackersCellViewModel(
                        id: tracker.id ?? UUID(),
                        color:
                            ColorMarshalling
                            .color(from: tracker.colorHex ?? ""),
                        name: tracker.name ?? "",
                        emoji: tracker.emoji ?? "",
                        recordCount: recordCount,
                        isRecordExists: isRecordExists,
                        currentDate: currentDate,
                        delegate: self,
                        rowNumber: rowNumber
                    )
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
    func didRecieveTracker(_ tracker: Tracker, forCategoryIndex categoryIndex: Int, allCategories: [String]) throws {
        let newTrackerCategory = TrackerCategory(title: allCategories[categoryIndex], trackers: [tracker], createdAt: Date())
        
        let isTrackerExists = trackerStore.checkForExisting(tracker: tracker)
        
        if isTrackerExists {
            let existingTracker = try trackerStore.getCDTracker(tracker: tracker)
            let existingCategory = try trackerCategoryStore.getCDTrackerCategoryFor(title: allCategories[categoryIndex])
            trackerStore.updateExistingTracker(existingTracker, with: tracker, for: existingCategory)
        } else {
            let isCategoryExist = trackerCategoryStore.checkForExisting(categoryTitle: allCategories[categoryIndex])
            
            if isCategoryExist {
                try trackerStore.addNewTracker(tracker, forCategoryTitle: allCategories[categoryIndex])
            } else {
                trackerCategoryStore.addNewTrackerCategory(newTrackerCategory)
                try trackerStore.addNewTracker(tracker, forCategoryTitle: allCategories[categoryIndex])
            }
        }
        
        let categoriesWithoutSelected = allCategories.filter { $0 != allCategories[categoryIndex] }
        for category in categoriesWithoutSelected {
            let trackerCategory = TrackerCategory(title: category, trackers: [], createdAt: Date())
            trackerCategoryStore.addNewTrackerCategory(trackerCategory)
        }
        showTrackersFor(date: currentDate, search: "")
    }
}
