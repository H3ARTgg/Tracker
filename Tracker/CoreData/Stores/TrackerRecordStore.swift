import CoreData
import UIKit

protocol TrackerRecordStoreProtocol: AnyObject {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord, for date: Date) throws
    func recordsCountFor(trackerID: UUID) -> Int
    func recordsCountForAll() -> Int
    func isRecordExistsFor(trackerID: UUID, and date: Date) -> Bool
    func getAllTrackerRecordsFor( _ trackerID: UUID) -> [TrackerRecord]
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext
    
    convenience init() {
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
    
    /// Возвращает количество выполненных дней для всех трекеров
    func recordsCountForAll() -> Int {
        let request = NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
        let records = try? context.fetch(request)
        return records != nil ? records!.count : 0
    }
    
    /// Возвращает массив TrackerRecord для конкретного UUID трекера
    func getAllTrackerRecordsFor( _ trackerID: UUID) -> [TrackerRecord] {
        let request = NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
        request.predicate = NSPredicate(format: "%K == %@", "id", trackerID as CVarArg)
        let records = try? context.fetch(request)
        var trackerRecords: [TrackerRecord] = []
        records?.forEach({
            guard let id = $0.id, let date = $0.date else { return }
            let trackerRecord = TrackerRecord(
                id: id,
                date: date
            )
            trackerRecords.append(trackerRecord)
        })
        return trackerRecords.sorted { $0.date < $1.date }
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
