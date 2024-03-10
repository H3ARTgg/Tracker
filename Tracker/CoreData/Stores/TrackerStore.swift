import CoreData
import UIKit

protocol TrackerStoreProtocol: AnyObject {
    /// Добовляет новый трекер в модель
    func addNewTracker(_ tracker: Tracker, forCategoryTitle category: String) throws
    /// Обновляет существующий CDTracker(entity)
    func updateExistingTracker(_ cdTracker: CDTracker, with tracker: Tracker, for category: CDTrackerCategory)
    /// Проверяет, есть ли данный трекер в модели
    func checkForExisting(tracker: Tracker) -> Bool
    /// Возвращает CDTracker(entity) по Tracker
    func getCDTracker(tracker: Tracker) throws -> CDTracker
    /// Возвращает CDTracker(entity) по UUID
    func getCDTracker(_ trackerID: UUID) throws -> CDTracker
    /// Создает предикаты и выполняет FetchResultController запрос
    func fetchTrackersByDayOfTheWeekFor(date: Date, searchText: String) throws
    /// Количество трекеров в result controller'е
    var trackers: [CDTracker]? { get }
    /// Возвращает массив CDTrackerCategory из Result Controller'а
    func getFetchedCategories() -> [CDTrackerCategory]
    func recreatePersistentContainer()
    func removeTracker(_ trackerID: UUID, for category: String)
    func updateExistingTrackerCategory(_ cdTracker: CDTracker, with category: CDTrackerCategory) throws
    func makeTrackersSamples()
}

// MARK: - TrackerStore
final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let trackerCategoryStore: TrackerCategoryStoreProtocol!
    private let weekDayStore = WeekDayStore()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<CDTracker> = {
        let fetchRequest = NSFetchRequest<CDTracker>(entityName: "CDTracker")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDTracker.category?.createdAt, ascending: true),
            NSSortDescriptor(keyPath: \CDTracker.createdAt, ascending: true)
        ]
        
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    convenience init(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("no AppDelegate")
            self.init(trackerCategoryStore: trackerCategoryStore)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context, trackerCategoryStore: trackerCategoryStore)
    }

    init(context: NSManagedObjectContext, trackerCategoryStore: TrackerCategoryStoreProtocol) throws {
        self.context = context
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    
    /// Добовляет новый трекер в модель
    func addNewTracker(_ tracker: Tracker, forCategoryTitle category: String) throws {
        let cdTracker = CDTracker(context: context)
        let cdCategory = try trackerCategoryStore.getCDTrackerCategoryFor(title: category)
        updateExistingTracker(cdTracker, with: tracker, for: cdCategory)
        try context.save()
    }

    /// Обновляет существующий CDTracker(entity)
    func updateExistingTracker(_ cdTracker: CDTracker, with tracker: Tracker, for category: CDTrackerCategory) {
        if let weekDays = tracker.daysOfTheWeek {
            let cdWeekDaysSet = weekDayStore.saveWeekDays(weekDays: weekDays, with: cdTracker)
            cdTracker.weekDays = cdWeekDaysSet
        }
        cdTracker.colorHex = ColorMarshalling.hexString(from: tracker.color)
        cdTracker.createdAt = tracker.createdAt
        cdTracker.id = tracker.id
        cdTracker.emoji = tracker.emoji
        cdTracker.name = tracker.name
        cdTracker.category = category
    }
    
    func updateExistingTrackerCategory(_ cdTracker: CDTracker, with category: CDTrackerCategory) throws {
        cdTracker.lastCategoryName = cdTracker.category?.title
        cdTracker.category = category
        try context.save()
    }
    
    /// Проверяет, есть ли данный трекер в модели
    func checkForExisting(tracker: Tracker) -> Bool {
        let request = NSFetchRequest<CDTracker>(entityName: "CDTracker")
        request.predicate = NSPredicate(format: "%K == %@", "id", tracker.id as CVarArg)
        do {
            let trackers = try context.fetch(request)
            return trackers.count > 0 ? true : false
        } catch {
            return false
        }
    }
    
    /// Возвращает CDTracker(entity) по Tracker
    func getCDTracker(tracker: Tracker) throws -> CDTracker {
        let request = NSFetchRequest<CDTracker>(entityName: "CDTracker")
        request.predicate = NSPredicate(format: "%K == %@", "id", tracker.id as CVarArg)
        let foundTrackers = try context.fetch(request)
        return foundTrackers[0]
    }
    /// Возвращает CDTracker(entity) по UUID
    func getCDTracker(_ trackerID: UUID) throws -> CDTracker {
        let request = NSFetchRequest<CDTracker>(entityName: "CDTracker")
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerID as CVarArg)
        let foundTrackers = try context.fetch(request)
        return foundTrackers[0]
    }
    
    /// Создает предикаты и выполняет FetchResultController запрос
    func fetchTrackersByDayOfTheWeekFor(date: Date, searchText: String) throws {
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(
            format: "%K.@count =0 OR (%K.@count >0 AND ANY %K =[cd] %ld)",
            #keyPath(CDTracker.weekDays),
            #keyPath(CDTracker.weekDays),
            #keyPath(CDTracker.weekDays.weekDay),
            date.weekDay()
        ))
        
        if searchText.count != 0 {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[cd] %@",
                #keyPath(CDTracker.name), searchText
            ))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try fetchedResultsController.performFetch()
    }
    
    func removeTracker(_ trackerID: UUID, for category: String) {
        let cdTracker = try! getCDTracker(trackerID)
        let cdCategory = try! trackerCategoryStore.getCDTrackerCategoryFor(title: category)
        context.delete(cdTracker)
        context.delete(cdCategory)
        try! context.save()
    }
    
    func makeTrackersSamples() {
        let trackerNames1 = ["Tracker_1", "Tracker_2", "Tracker_3", "Tracker_4"]
        let trackerNames2 = ["Tracker_5", "Tracker_6", "Tracker_7", "Tracker_8"]
        var trackerArray1: [Tracker] = []
        var trackerArray2: [Tracker] = []
        for name in trackerNames1 {
            let tracker = Tracker(
                id: UUID(),
                name: name,
                color: (.selectionColors.randomElement()! ?? .black),
                emoji: String.emojisArray.randomElement() ?? "🌺 ",
                daysOfTheWeek: nil,
                createdAt: Date()
            )
            trackerArray1.append(tracker)
        }
        for name in trackerNames2 {
            let tracker = Tracker(
                id: UUID(),
                name: name,
                color: (.selectionColors.randomElement()! ?? .black),
                emoji: String.emojisArray.randomElement() ?? "🌺 ",
                daysOfTheWeek: nil,
                createdAt: Date()
            )
            trackerArray2.append(tracker)
        }
        
        let firstCategory = TrackerCategory(title: "Category_1", trackers: trackerArray1, createdAt: Date())
        let secondCategoty = TrackerCategory(title: "Category_2", trackers: trackerArray2, createdAt: Date())
        
        trackerCategoryStore.addNewTrackerCategory(firstCategory)
        trackerCategoryStore.addNewTrackerCategory(secondCategoty)
        
        trackerArray1.forEach { [weak self] in
            try? self?.addNewTracker($0, forCategoryTitle: firstCategory.title)
        }
        
        trackerArray2.forEach { [weak self] in
            try? self?.addNewTracker($0, forCategoryTitle: secondCategoty.title)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

extension TrackerStore {
    /// Количество трекеров в result controller'е
    var trackers: [CDTracker]? {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    /// Возвращает массив CDTrackerCategory из Result Controller'а
    func getFetchedCategories() -> [CDTrackerCategory] {
        var set: Set<CDTrackerCategory> = []
        fetchedResultsController.fetchedObjects?.forEach({
            set.insert($0.category!)
        })
        var array: [CDTrackerCategory] = []
        set.forEach { array.append($0) }
        return array
    }
    
    func recreatePersistentContainer() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("no AppDelegate")
            return
        }
        appDelegate.recreatePersistentContainer()
    }
}
