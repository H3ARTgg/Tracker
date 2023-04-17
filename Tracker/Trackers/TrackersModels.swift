import Foundation
import UIKit

enum DaysOfTheWeek: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
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


