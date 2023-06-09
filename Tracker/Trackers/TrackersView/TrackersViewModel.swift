import UIKit
protocol TrackersViewModelDelegate {
    func updateCompletedTrackers()
}

final class TrackersViewModel: NewTrackerDelegate {
    private var currentDate: Date
    private let trackerCategoryStore: TrackerCategoryStoreProtocol!
    private let trackerStore: TrackerStoreProtocol!
    private let trackerRecordStore: TrackerRecordStoreProtocol!
    private let weekDayStore: WeekDayStoreProtocol!
    private let analyticsService: AnalyticsServiceProtocol!
    private let pinnedTitle = NSLocalizedString(.localeKeys.pinned, comment: "")
    private(set) var stringCategories: [String] = []
    @Observable private(set) var trackersCategories: [TrackersSupplementaryViewModel] = []
    var delegate: TrackersViewModelDelegate?
    
    init(date: Date, trackerCategoryStore: TrackerCategoryStoreProtocol, trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStoreProtocol, weekDayStore: WeekDayStoreProtocol, analyticsService: AnalyticsServiceProtocol) {
        self.currentDate = date
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        self.weekDayStore = weekDayStore
        self.analyticsService = analyticsService
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
        
        let sortedTrackerCategories = trackerCategories.sorted { $0.title < $1.title }
        var withoutPinnedSortedCategories = sortedTrackerCategories.filter { [weak self] in
            $0.title != self?.pinnedTitle
        }
        if let pinnedCategory = trackerCategories.first(where: { [weak self] in
            $0.title == self?.pinnedTitle
        }) {
            withoutPinnedSortedCategories.insert(pinnedCategory, at: 0)
        }
        return withoutPinnedSortedCategories
    }
    
    /// Показывает трекеры для конкретной даты (и поиска)
    func showTrackersFor(date: Date, search: String) {
        self.currentDate = date
        try? trackerStore.fetchTrackersByDayOfTheWeekFor(date: currentDate, searchText: search)
        trackersCategories = getTrackersCategories()
        stringCategories = trackerCategoryStore.getAllCategoriesTitles()
    }
    
    /// Настройка ячейки для данного IndexPath
    func configure(_ cell: TrackersCell, for indexPath: IndexPath, interactionDelegate: UIContextMenuInteractionDelegate) {
        cell.interactionDelegate = interactionDelegate
        cell.viewModel = trackersCategories[indexPath.section].trackers[indexPath.row]
    }
    
    /// Возвращает ViewModel для NewTrackerViewController
    func getViewModelForNewTracker() -> NewTrackerViewModel {
        analyticsService.reportWishToCreateTracker()
        return NewTrackerViewModel(delegate: self)
    }
    
    /// Закрепляет ячейку
    func pin(_ cell: TrackersCell) {
        let cdTracker = try! trackerStore.getCDTracker(cell.viewModel.id)
        
        let isPinnedCategoryExists = trackerCategoryStore.checkForExisting(categoryTitle: pinnedTitle)
        if isPinnedCategoryExists {
            let cdCategory = try! trackerCategoryStore.getCDTrackerCategoryFor(title: pinnedTitle)
            try? trackerStore.updateExistingTrackerCategory(cdTracker, with: cdCategory)
        } else {
            let pinnedTrackerCategory = TrackerCategory(title: pinnedTitle, trackers: [Tracker(id: UUID(), name: "", color: .white, emoji: "", daysOfTheWeek: nil, createdAt: Date())], createdAt: Date())
            trackerCategoryStore.addNewTrackerCategory(pinnedTrackerCategory)
            let cdCategory = try! trackerCategoryStore.getCDTrackerCategoryFor(title: pinnedTitle)
            try? trackerStore.updateExistingTrackerCategory(cdTracker, with: cdCategory)
        }
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Открепляет ячейку
    func unpin(_ cell: TrackersCell) {
        let cdTracker = try! trackerStore.getCDTracker(cell.viewModel.id)
        let cdCategory = try! trackerCategoryStore.getCDTrackerCategoryFor(title: cdTracker.lastCategoryName ?? "")
        
        try? trackerStore.updateExistingTrackerCategory(cdTracker, with: cdCategory)
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Проверяет на закрепленность ячейки с возвратом булевой переменной
    func isPinned(_ cell: TrackersCell) -> Bool {
        guard let pinnedCategory = trackersCategories.first(where: { [weak self] in
            $0.title == self?.pinnedTitle}) else {
            return false
        }
        return pinnedCategory.trackers.contains { $0.id == cell.viewModel.id }
    }
    
    /// Удаляет трекер
    func delete(_ cell: TrackersCell) {
        for category in trackersCategories {
            if category.trackers.contains(where: { $0.id == cell.viewModel.id }) {
                trackerStore.removeTracker(cell.viewModel.id, for: category.title)
                break
            }
        }
        analyticsService.reportTrackerDeletion()
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Узнать, какой выбор у ячейки (привычка или событие)
    private func findOutChoiceFor(_ cell: TrackersCell) -> Choice {
        let cdTracker = try! trackerStore.getCDTracker(cell.viewModel.id)
        if let weekDays = cdTracker.weekDays {
            if weekDays.count > 0 {
                return .habit
            }
        }
        return .event
    }
    
    /// Возвращает HabitOrEventViewModel
    func getHabitOrEventViewModel(with cell: TrackersCell) -> HabitOrEventViewModel {
        let cdTracker = try! trackerStore.getCDTracker(cell.viewModel.id)
        let choice = findOutChoiceFor(cell)
        let tracker = Tracker(
            id: cdTracker.id ?? UUID(),
            name: cdTracker.name ?? "",
            color: ColorMarshalling.color(from: cdTracker.colorHex ?? ""),
            emoji: cdTracker.emoji ?? "",
            daysOfTheWeek: weekDayStore.getWeekDaysFrom(cdTracker.weekDays ?? NSSet()),
            createdAt: cdTracker.createdAt ?? Date()
        )
        let trackerCategory = TrackerCategory(title: cdTracker.category?.title ?? "", trackers: [tracker], createdAt: Date())
        let recordCount = trackerRecordStore.recordsCountFor(trackerID: cell.viewModel.id)
        let trackerEdit = TrackerEdit(recordCount: recordCount, trackerCategory: trackerCategory)
        return HabitOrEventViewModel(choice: .edit(choice), delegate: self, trackerEdit: trackerEdit)
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
        
        delegate?.updateCompletedTrackers()
    }
}

// MARK: - HabitOrEventDelegate
extension TrackersViewModel: HabitOrEventDelegate {
    func didRecieveTracker(_ tracker: Tracker, category: String, allCategories: [String], recordCount: Int?) throws {
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
        
        if let recordCount = recordCount {
            countNewRecords(recordCount, for: tracker)
        }
        showTrackersFor(date: currentDate, search: "")
    }
    
    private func countNewRecords(_ recordCount: Int, for tracker: Tracker) {
        let currentRecordCount = trackerRecordStore.recordsCountFor(trackerID: tracker.id)
        let allRecords = trackerRecordStore.getAllTrackerRecordsFor(tracker.id)
        if recordCount < currentRecordCount {
            if recordCount == 0 {
                allRecords.forEach { [weak self] in
                    try? self?.trackerRecordStore.deleteTrackerRecord($0, for: $0.date)
                }
            }
            
            if recordCount != 0 {
                let newCount = currentRecordCount - recordCount
                for i in 0..<newCount {
                    try? trackerRecordStore.deleteTrackerRecord(allRecords[i], for: allRecords[i].date)
                }
            }
        }
        
        if recordCount > currentRecordCount {
            let newCount = recordCount - currentRecordCount
            let lastDateRecord = allRecords.first?.date ?? Date()
            for i in 0..<newCount {
                let newDate = Date().createDay(
                    day: lastDateRecord.day() - i,
                    month: lastDateRecord.month(),
                    year: lastDateRecord.year()
                )
                try? trackerRecordStore.addTrackerRecord(TrackerRecord(id: tracker.id, date: newDate))
            }
        }
    }
}
