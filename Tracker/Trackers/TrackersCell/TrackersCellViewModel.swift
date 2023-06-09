import Foundation
import UIKit

struct TrackersCellViewModelSample {
    let id: UUID
    let color: UIColor
    let name: String
    let emoji: String
    let recordCount: Int
    let isRecordExists: Bool
    let currentDate: Date
    let delegate: TrackersCellDelegate
    let rowNumber: Int
}

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
            daysRecordText = String.localizedStringWithFormat(
                NSLocalizedString(.localeKeys.numberOfDays, comment: ""),
                recordCount)
        }
    }
    @Observable private(set) var daysRecordText: String = "0 дней"
    
    init(cellSample: TrackersCellViewModelSample) {
        self.id = cellSample.id
        self.color = cellSample.color
        self.name = cellSample.name
        self.emoji = cellSample.emoji
        self.recordCount = cellSample.recordCount
        self.isRecordExists = cellSample.isRecordExists
        self.currentDate = cellSample.currentDate
        self.delegate = cellSample.delegate
        self.rowNumber = cellSample.rowNumber
        self.daysRecordText = String.localizedStringWithFormat(
            NSLocalizedString(.localeKeys.numberOfDays, comment: ""),
            recordCount)
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
