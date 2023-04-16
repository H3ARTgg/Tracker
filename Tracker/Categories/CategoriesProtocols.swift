import Foundation

protocol CategoriesViewControllerDelegate: AnyObject {
    func selectedCategory(indexPath: IndexPath, categories: [String])
}

protocol CategoriesViewControllerProtocol: AnyObject {
    var delegate: CategoriesViewControllerDelegate? { get set }
    func recieveCategories(categories: [String], currentAt: IndexPath?)
}
