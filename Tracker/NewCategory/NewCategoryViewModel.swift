protocol NewCategoryDelegate {
    func addNewCategory(_ category: String)
}

final class NewCategoryViewModel {
    private let delegate: NewCategoryDelegate
    
    init(delegate: NewCategoryDelegate) {
        self.delegate = delegate
    }
    
    func addNewCategory(_ category: String) {
        delegate.addNewCategory(category)
    }
}
