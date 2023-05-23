import Foundation
import UIKit

final class TrackersCellViewModel: Identifiable {
    private let delegate: TrackersCellDelegate
    private let currentDate: Date
    let id: UUID
    let color: UIColor
    let name: String
    let emoji: String
    let isRecordExists: Bool
    let rowNumber: Int
    
    private(set) var recordCount: Int {
        didSet {
            daysRecordText = DaysOfTheWeek.getRightTextDeclinationFor(recordCount: recordCount)
        }
    }
    @Observable private(set) var daysRecordText: String = "0 дней"
    
    init(id: UUID,
         color: UIColor,
         name: String,
         emoji: String,
         recordCount: Int,
         isRecordExists: Bool,
         currentDate: Date,
         delegate: TrackersCellDelegate,
         rowNumber: Int) {
        self.id = id
        self.color = color
        self.name = name
        self.emoji = emoji
        self.recordCount = recordCount
        self.isRecordExists = isRecordExists
        self.currentDate = currentDate
        self.delegate = delegate
        self.rowNumber = rowNumber
        self.daysRecordText = DaysOfTheWeek.getRightTextDeclinationFor(recordCount: recordCount)
    }
    
    func isDateBiggerThanRealTime() -> Bool {
        currentDate.isBiggerThanRealTime()
    }
    
    func didAddDay(_ check: Bool) {
        if check {
            recordCount += 1
            delegate.didRecieveNewRecord(true, for: id)
        } else {
            recordCount -= 1
            delegate.didRecieveNewRecord(false, for: id)
        }
    }
}
