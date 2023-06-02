import UIKit

final class CategoriesViewModel {
    private let delegate: CategoriesDelegate
    @Observable private(set) var selectedCategory: IndexPath?
    @Observable private(set) var previousSelectedCategory = IndexPath(row: 0, section: 0)
    @Observable private(set) var stringCategories: [String] = []
    
    init(
        delegate: CategoriesDelegate,
        categories: [String],
        selectedAt: Int?
    ) {
        self.delegate = delegate
        self.stringCategories = categories
        if let selectedAt = selectedAt {
            self.selectedCategory = IndexPath(row: selectedAt, section: 0)
        }
    }
    
    func provideCategories(selected: IndexPath) {
        delegate.selectedCategory(indexPath: selected, categories: stringCategories)
    }
    
    func getViewModelForNewCategory() -> NewCategoryViewModel  {
        NewCategoryViewModel(delegate: self)
    }
}

extension CategoriesViewModel: NewCategoryDelegate {
    func addNewCategory(_ category: String) {
        if stringCategories.contains(category) {
            return
        }
        stringCategories.append(category)
        if let selectedCategory = selectedCategory {
            previousSelectedCategory = selectedCategory
        }
        selectedCategory = IndexPath(row: stringCategories.count - 1, section: 0)
    }
}
