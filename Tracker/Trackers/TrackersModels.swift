import Foundation
import UIKit

enum DaysOfTheWeek {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    let daysOfTheWeek: [DaysOfTheWeek]?
    let date: Date
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UInt
}


