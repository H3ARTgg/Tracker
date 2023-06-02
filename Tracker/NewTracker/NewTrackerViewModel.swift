final class NewTrackerViewModel {
    private let delegate: NewTrackerDelegate
    
    /// Возвращает ViewModel для HabitOrEventViewController
    func getViewModelForHabitOrEventWith(_ choice: Choice) -> HabitOrEventViewModel? {
        guard let habitOrEventDelegate = delegate as? HabitOrEventDelegate else {
            assertionFailure("NewTrackerDelegate isn't a HabitOrEventDelegate")
            return nil
        }
        return HabitOrEventViewModel(
            choice: choice,
            delegate: habitOrEventDelegate
        )
    }
    
    init(delegate: NewTrackerDelegate) {
        self.delegate = delegate
    }
}
