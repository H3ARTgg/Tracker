import Foundation

struct WeekDay {
    var weekDay: Int = 2
    var cellRow: Int? = nil
    let everyday: String = NSLocalizedString(.localeKeys.everyDay, comment: "Every day text")
    /// Сокращенное название дня недели
    var shortName: String {
        switch weekDay {
        case 2:
            return NSLocalizedString(.localeKeys.mondayShort, comment: "Short form of monday")
        case 3:
            return NSLocalizedString(.localeKeys.tuesdayShort, comment: "Short form of tuesday")
        case 4:
            return NSLocalizedString(.localeKeys.wednesdayShort, comment: "Short form of wednesday")
        case 5:
            return NSLocalizedString(.localeKeys.thursdayShort, comment: "Short form of thursday")
        case 6:
            return NSLocalizedString(.localeKeys.fridayShort, comment: "Short form of friday")
        case 7:
            return NSLocalizedString(.localeKeys.saturdayShort, comment: "Short form of saturday")
        case 1:
            return NSLocalizedString(.localeKeys.sundayShort, comment: "Short form of sunday")
        default:
            return everyday
        }
    }
    /// Длинное название дня недели
    var longName: String {
        switch weekDay {
        case 2:
            return NSLocalizedString(.localeKeys.mondayLong, comment: "Long form of monday")
        case 3:
            return NSLocalizedString(.localeKeys.tuesdayLong, comment: "Long form of tuesday")
        case 4:
            return NSLocalizedString(.localeKeys.wednesdayLong, comment: "Long form of wednesday")
        case 5:
            return NSLocalizedString(.localeKeys.thursdayLong, comment: "Long form of thursday")
        case 6:
            return NSLocalizedString(.localeKeys.fridayLong, comment: "Long form of friday")
        case 7:
            return NSLocalizedString(.localeKeys.saturdayLong, comment: "Long form of saturday")
        case 1:
            return NSLocalizedString(.localeKeys.sundayLong, comment: "Long form of sunday")
        default:
            return everyday
        }
    }
    /// Длинное название дня недели для ячейки (вариация для ScheduleViewController)
    var longNameForCell: String {
        switch cellRow {
        case 0:
            return NSLocalizedString(.localeKeys.mondayLong, comment: "Long form of monday")
        case 1:
            return NSLocalizedString(.localeKeys.tuesdayLong, comment: "Long form of tuesday")
        case 2:
            return NSLocalizedString(.localeKeys.wednesdayLong, comment: "Long form of wednesday")
        case 3:
            return NSLocalizedString(.localeKeys.thursdayLong, comment: "Long form of thursday")
        case 4:
            return NSLocalizedString(.localeKeys.fridayLong, comment: "Long form of friday")
        case 5:
            return NSLocalizedString(.localeKeys.saturdayLong, comment: "Long form of saturday")
        case 6:
            return NSLocalizedString(.localeKeys.sundayLong, comment: "Long form of sunday")
        default:
            return everyday
        }
    }
    
    init(weekDay: Int) {
        self.weekDay = weekDay
    }
    
    init(cellRow: Int) {
        self.cellRow = cellRow
        
        switch cellRow {
        case 0:
            weekDay = 2
        case 1:
            weekDay = 3
        case 2:
            weekDay = 4
        case 3:
            weekDay = 5
        case 4:
            weekDay = 6
        case 5:
            weekDay = 7
        case 6:
            weekDay = 1
        default:
            assertionFailure("out of cases")
        }
    }
}
