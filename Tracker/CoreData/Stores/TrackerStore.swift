import CoreData
import UIKit

// MARK: - Delegate Protocol
protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let weekDayStore = WeekDayStore()
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
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

    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("no AppDelegate")
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
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
        cdTracker.colorHex = uiColorMarshalling.hexString(from: tracker.color)
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
    func showTrackersByDayOfTheWeekFor(date: Date, searchText: String) throws {
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
        
        delegate?.didUpdate()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

extension TrackerStore {
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

    /// Возвращает количество полученных категорий
    func numberOfFetchedCategories() -> Int {
        var set: Set<CDTrackerCategory> = []
        fetchedResultsController.fetchedObjects?.forEach({
            set.insert($0.category!)
        })
        return set.count
    }
}
