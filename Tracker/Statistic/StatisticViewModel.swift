final class StatisticViewModel {
    @Observable private(set) var recordCount: Int = 0
    let statisticRecords: StatisticRecordsProvider?
    
    init(statisticRecords: StatisticRecordsProvider) {
        self.statisticRecords = statisticRecords
        self.recordCount = statisticRecords.recordsCountForAll()
    }
}

extension StatisticViewModel: TrackersViewModelDelegate {
    func updateCompletedTrackers() {
        if let statisticRecords {
            recordCount = statisticRecords.recordsCountForAll()
        }
    }
}
