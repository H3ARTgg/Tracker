import UIKit
import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let daysOfTheWeek: [WeekDay]?
    let createdAt: Date
}
