import CoreData
import UIKit

protocol WeekDayStoreProtocol: AnyObject {
    func saveWeekDays(weekDays: [WeekDay], with cdTracker: CDTracker) -> NSSet
}

final class WeekDayStore: WeekDayStoreProtocol {
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
    
    /// Сохраняет WeekDays в модели, привязывает к трекеру и возвращает NSSet WeekDays
    func saveWeekDays(weekDays: [WeekDay], with cdTracker: CDTracker) -> NSSet {
        var cdWeekDayArray: [CDWeekDay] = []
        weekDays.forEach {
            let cdWeekDay = CDWeekDay(context: context)
            cdWeekDay.weekDay = Int32($0.weekDay)
            cdWeekDay.tracker = cdTracker
            cdWeekDayArray.append(cdWeekDay)
        }
        
        return NSSet(array: cdWeekDayArray)
    }
}
