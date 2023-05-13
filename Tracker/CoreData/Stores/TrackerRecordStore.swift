import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
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
    
    /// Добавляет выполненный день
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let cdTrackerRecord = CDTrackerRecord(context: context)
        cdTrackerRecord.id = trackerRecord.id
        cdTrackerRecord.date = trackerRecord.date
        try context.save()
    }
    
    /// Удаляет выполненный день
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord, for date: Date) throws {
        let request = NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerRecord.id as CVarArg)
        let cdTrackerRecords = try context.fetch(request)
        let filteredRecords = cdTrackerRecords.filter {
            $0.date!.hasSame([.day, .month, .year], as: date)
        }
        context.delete(filteredRecords[0])
        try context.save()
    }
    
    /// Возвращает количество выполненных дней трекера
    func recordsCountFor(trackerID: UUID) -> Int {
        let request = NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerID as CVarArg)
        let records = try? context.fetch(request)
        return records != nil ? records!.count : 0
    }
    
    /// Проверяет, выполнен ли трекер для данного дня
    func isRecordExistsFor(trackerID: UUID, and date: Date) -> Bool {
        let request = NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerID as CVarArg)
        let records = try? context.fetch(request)
        var check: Bool = false
        if records != nil {
            records?.forEach({
                if $0.date!.hasSame([.day, .month, .year], as: date) {
                    check = true
                }
            })
        }
        return check
    }
}
