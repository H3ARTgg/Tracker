import Foundation

protocol CategoriesDelegate: AnyObject {
    func selectedCategory(indexPath: IndexPath, categories: [String])
}
