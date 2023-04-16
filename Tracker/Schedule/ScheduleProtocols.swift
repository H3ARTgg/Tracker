import Foundation

protocol ScheduleCellDelegate: AnyObject {
    func choiceForDay(_ check: Bool, indexPath: IndexPath)
}

protocol ScheduleViewControllerProtocol: AnyObject {
    var delegate: ScheduleViewControllerDelegate? { get set }
    func recieveDaysOfTheWeek(daysOfTheWeek: [Int: DaysOfTheWeek])
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [Int: DaysOfTheWeek])
}

