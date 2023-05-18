import Foundation
import UIKit

struct TrackersCellViewModel {
    let id: UUID
    let color: UIColor
    let name: String
    let emoji: String
    let recordCount: Int
    let isRecordExists: Bool
    let currentDate: Date
    let delegate: TrackersCellDelegate
    let number: Int
}
