import Foundation

protocol ScheduleCellDelegate: AnyObject {
    func choiceForDay(_ isSwitherOn: Bool, indexPath: IndexPath)
}

protocol ScheduleViewControllerProtocol: AnyObject {
    var delegate: ScheduleViewControllerDelegate? { get set }
    func recieveDaysOfTheWeek(daysOfTheWeek: [WeekDay])
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [WeekDay])
}

