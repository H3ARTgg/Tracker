import CoreData
import UIKit

// MARK: - TrackerStore
final class TrackerStore: NSObject {
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

extension TrackerStore {
    var trackers: [CDTracker]? {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    /// Возвращает количество секций
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    /// Возвращает количество ячеек в секции
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    /// Возвращает CDTracker для конкретного IndexPath
    func object(at indexPath: IndexPath) -> CDTracker? {
        fetchedResultsController.object(at: indexPath)
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
