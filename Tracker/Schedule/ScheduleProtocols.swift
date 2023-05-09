import Foundation

protocol ScheduleCellDelegate: AnyObject {
    func choiceForDay(_ check: Bool, indexPath: IndexPath)
}

protocol ScheduleViewControllerProtocol: AnyObject {
    var delegate: ScheduleViewControllerDelegate? { get set }
    func recieveDaysOfTheWeek(daysOfTheWeek: [Int: WeekDay])
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [Int: WeekDay])
}

