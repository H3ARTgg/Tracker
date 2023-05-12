import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    private let context: NSManagedObjectContext
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("no AppDelegate")
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    /// Возвращает CDTrackerCategory(entity) по заголовку трекера-категории
    func getCDTrackerCategoryFor(title : String) throws -> CDTrackerCategory {
        let request = NSFetchRequest<CDTrackerCategory>(entityName: "CDTrackerCategory")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(CDTrackerCategory.title), title)
        let category = try context.fetch(request)
        return category[0]
    }
    
    /// Проверяет, есть ли данный трекер-категория в модели
    func checkForExisting(categoryTitle: String) -> Bool {
        let request = NSFetchRequest<CDTrackerCategory>(entityName: "CDTrackerCategory")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(CDTrackerCategory.title), categoryTitle)
        do {
            let categories = try context.fetch(request)
            return categories.count > 0 ? true : false
        } catch {
            return false
        }
    }
    
    /// Возвращает заголовки всех трекер-категорий в модели
    func getAllCategoriesTitles() throws -> [String] {
        let request = NSFetchRequest<CDTrackerCategory>(entityName: "CDTrackerCategory")
        request.propertiesToFetch = ["title"]
        var titleArray: [String] = []
        let categoriesTitles = try context.fetch(request)
        categoriesTitles.forEach {
            guard let title = $0.title else { return }
            titleArray.append(title)
        }
        return titleArray
    }
    
    /// Добавляет новую трекер-категорию в модель
    func addNewTrackerCategory(_ trakerCategory: TrackerCategory) {
        let cdCategory = CDTrackerCategory(context: context)
        cdCategory.createdAt = trakerCategory.createdAt
        cdCategory.title = trakerCategory.title
    }
}
