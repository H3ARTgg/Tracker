import CoreData
import UIKit

final class WeekDayStore {
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
    
    func convertFrom(nsSet: NSSet?) -> [WeekDay]? {
        if let nsSet = nsSet {
            var weekDays: [WeekDay] = []
            nsSet.forEach { dayAny in
                guard let cdWeekDay = dayAny as? CDWeekDay else { return }
                let weekDay = WeekDay(weekDay: Int(cdWeekDay.weekDay))
                weekDays.append(weekDay)
            }
            return weekDays
        } else {
            return nil
        }
    }
}
