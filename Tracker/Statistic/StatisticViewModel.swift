final class StatisticViewModel {
    @Observable private(set) var recordCount: Int = 0
    let trackerRecordStore: TrackerRecordStoreProtocol!
    
    init(trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerRecordStore = trackerRecordStore
        self.recordCount = trackerRecordStore.recordsCountForAll()
    }
}

extension StatisticViewModel: TrackersViewModelDelegate {
    func updateCompletedTrackers() {
        recordCount = trackerRecordStore.recordsCountForAll()
    }
}
