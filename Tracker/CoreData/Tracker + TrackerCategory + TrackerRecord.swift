import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let daysOfTheWeek: [WeekDay]?
    let createdAt: Date
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    let createdAt: Date
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}


