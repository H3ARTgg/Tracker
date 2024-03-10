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
                let isPinned = category.title == NSLocalizedString(.localeKeys.pinned, comment: "") ? true : false
                let trackersCellViewModelSample = TrackersCellViewModelSample(
                    id: tracker.id ?? UUID(),
                    color: ColorMarshalling.color(from: tracker.colorHex ?? ""),
                    name: tracker.name ?? "",
                    emoji: tracker.emoji ?? "",
                    recordCount: recordCount,
                    isRecordExists: isRecordExists,
                    currentDate: currentDate,
                    delegate: self,
                    rowNumber: rowNumber,
                    isPinned: isPinned
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
        report(event: .click, screen: .trackersList, item: .addTracker)
        return NewTrackerViewModel(delegate: self)
    }
    
    /// Закрепляет трекер
    func pin(_ trackerId: UUID) {
        let cdTracker = try! trackerStore.getCDTracker(trackerId)
        
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
    
    /// Открепляет трекер
    func unpin(_ trackerId: UUID) {
        let cdTracker = try! trackerStore.getCDTracker(trackerId)
        let cdCategory = try! trackerCategoryStore.getCDTrackerCategoryFor(title: cdTracker.lastCategoryName ?? "")
        try? trackerStore.updateExistingTrackerCategory(cdTracker, with: cdCategory)
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Проверяет на закрепленность трекера с возвратом булевой переменной
    func isPinned(_ trackerId: UUID) -> Bool {
        guard let pinnedCategory = trackersCategories.first(where: { [weak self] in
            $0.title == self?.pinnedTitle}) else {
            return false
        }
        return pinnedCategory.trackers.contains { $0.id == trackerId }
    }
    
    /// Удаляет трекер
    func delete(_ trackerId: UUID) {
        for category in trackersCategories {
            if category.trackers.contains(where: { $0.id == trackerId }) {
                trackerStore.removeTracker(trackerId, for: category.title)
                do {
                    try trackerRecordStore.removeAllTrackerRecords(for: trackerId)
                } catch {
                    assertionFailure("Can't delete tracker records")
                }
                break
            }
        }
        report(event: .click, screen: .trackersList, item: .delete)
        showTrackersFor(date: currentDate, search: "")
    }
    
    /// Узнать, какой выбор у ячейки (привычка или событие)
    private func findOutChoiceFor(_ trackerId: UUID) -> Choice {
        let cdTracker = try! trackerStore.getCDTracker(trackerId)
        if let weekDays = cdTracker.weekDays {
            if weekDays.count > 0 {
                return .habit
            }
        }
        return .event
    }
    
    /// Возвращает HabitOrEventViewModel
    func getHabitOrEventViewModel(with trackerId: UUID) -> HabitOrEventViewModel {
        let cdTracker = try! trackerStore.getCDTracker(trackerId)
        let choice = findOutChoiceFor(trackerId)
        let tracker = Tracker(
            id: cdTracker.id ?? UUID(),
            name: cdTracker.name ?? "",
            color: ColorMarshalling.color(from: cdTracker.colorHex ?? ""),
            emoji: cdTracker.emoji ?? "",
            daysOfTheWeek: weekDayStore.getWeekDaysFrom(cdTracker.weekDays ?? NSSet()),
            createdAt: cdTracker.createdAt ?? Date()
        )
        let trackerCategory = TrackerCategory(title: cdTracker.category?.title ?? "", trackers: [tracker], createdAt: Date())
        let recordCount = trackerRecordStore.recordsCountFor(trackerID: trackerId)
        let trackerEdit = TrackerEdit(recordCount: recordCount, trackerCategory: trackerCategory)
        return HabitOrEventViewModel(choice: .edit(choice), delegate: self, trackerEdit: trackerEdit)
    }
    
    func report(event: Event, screen: Screen, item: Item?) {
        analyticsService.report(event: event, screen: screen, item: item)
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
            try? trackerRecordStore.removeTrackerRecord(newRecord, for: currentDate)
        }
        
        delegate?.updateCompletedTrackers()
        report(event: .click, screen: .trackersList, item: .doneTracker)
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
                    try? self?.trackerRecordStore.removeTrackerRecord($0, for: $0.date)
                }
            }
            
            if recordCount != 0 {
                let newCount = currentRecordCount - recordCount
                for i in 0..<newCount {
                    try? trackerRecordStore.removeTrackerRecord(allRecords[i], for: allRecords[i].date)
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
