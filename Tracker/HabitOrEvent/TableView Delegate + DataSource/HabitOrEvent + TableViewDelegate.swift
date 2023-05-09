import UIKit

extension HabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCategoriesViewController()
        }
        
        if indexPath.row == 1 {
            showScheduleViewController()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    private func showCategoriesViewController() {
        let categoriesVC = CategoriesViewController()
        categoriesVC.modalPresentationStyle = .popover
        categoriesVC.delegate = self
        categoriesVC.recieveCategories(categories: self.stringCategories, currentAt: self.selectedCategory)
        textField.resignFirstResponder()
        present(categoriesVC, animated: true)
    }
    
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.modalPresentationStyle = .popover
        scheduleVC.delegate = self
        scheduleVC.recieveDaysOfTheWeek(daysOfTheWeek: self.daysOfTheWeek)
        textField.resignFirstResponder()
        present(scheduleVC, animated: true)
    }
}
