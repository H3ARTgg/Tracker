import Foundation
import UIKit

protocol HabitOrEventDelegate: AnyObject {
    var stringCategories: [String] { get }
    func didRecieveTracker(_ tracker: Tracker, category: String, allCategories: [String]) throws
}

final class HabitOrEventViewModel {
    let choice: Choice
    let delegate: HabitOrEventDelegate
    private(set) var daysOfTheWeek: [Int: WeekDay] = [:]
    private var selectedEmoji: IndexPath?
    private var selectedColor: IndexPath?
    @Observable private(set) var oldSelectedEmojiIndex = IndexPath(row: 0, section: 0)
    @Observable private(set) var oldSelectedColorIndex = IndexPath(row: 0, section: 1)
    @Observable private(set) var stringCategories: [String] = []
    @Observable private(set) var selectedCategory: String?
    @Observable private(set) var stringForScheduleCell: String = "Расписание"
    
    init(choice: Choice, delegate: HabitOrEventDelegate) {
        self.choice = choice
        self.delegate = delegate
        self.stringCategories = delegate.stringCategories
    }
    
    /// Создать трекер и передать делегату
    func didTapCreateButton(text: String?) {
        if
            let selectedEmoji = selectedEmoji,
            let selectedColor = selectedColor,
            let selectedCategory = selectedCategory,
            let text = text,
            text.count != 0 {
            
            var daysValues: [WeekDay]?
            if choice == Choice.habit && daysOfTheWeek.count != 0 {
                daysValues = daysOfTheWeek.map(\.value)
            }
            
            let tracker = Tracker(
                id: UUID(),
                name: text,
                color: UIColor.selectionColors[selectedColor.row]!,
                emoji: String.emojisArray[selectedEmoji.row],
                daysOfTheWeek: daysValues ?? nil,
                createdAt: Date()
            )
            try? delegate.didRecieveTracker(tracker, category: selectedCategory, allCategories: self.stringCategories)
        }
    }
        
    /// Проверяет готовность к созданию трекера. True - если все пункты выбраны или заполнены.
    func isReadyForCreate(text: String?) -> Bool {
        if
            let _ = selectedEmoji,
            let _ = selectedColor,
            let _ = selectedCategory,
            let text = text,
            text.count != 0 {
            switch choice {
            case .habit:
                if !daysOfTheWeek.isEmpty {
                    return true
                } else {
                    return false
                }
            case .event:
                return true
            }
        } else {
            return false
        }
    }
    
    /// Выбирает эмодзи
    func selectEmoji(at indexPath: IndexPath) {
        oldSelectedEmojiIndex = selectedEmoji ?? IndexPath(row: 0, section: 0)
        selectedEmoji = indexPath
    }
    
    /// Выбирает цвет
    func selectColor(at indexPath: IndexPath) {
        oldSelectedColorIndex = selectedColor ?? IndexPath(row: 0, section: 1)
        selectedColor = indexPath
    }
    
    /// Возвращает ViewModel для CategoriesViewController
    func getViewModelForCategories() -> CategoriesViewModel {
        let selectedCategoryIndex = stringCategories
            .firstIndex(of: selectedCategory ?? "") ?? nil
        return CategoriesViewModel(
            delegate: self,
            categories: stringCategories,
            selectedAt: selectedCategoryIndex
        )
    }
}

// MARK: - CategoriesDelegate
extension HabitOrEventViewModel: CategoriesDelegate {
    func selectedCategory(indexPath: IndexPath, categories: [String]) {
        self.stringCategories = categories
        selectedCategory = categories[indexPath.row]
    }
}

// MARK: - ScheduleViewControllerDelegate
extension HabitOrEventViewModel: ScheduleViewControllerDelegate {
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [Int: WeekDay]) {
        self.daysOfTheWeek.removeAll()
        self.daysOfTheWeek = daysOfTheWeek
        
        if daysOfTheWeek.count > 0 {
            stringForScheduleCell = makeDetailStringForScheduleCell()
        } else if daysOfTheWeek.isEmpty {
            stringForScheduleCell = "Расписание"
        }
    }
    
    /// Возвращает дополнительный текст для обозначения выбранных дней недели для ячейки
    private func makeDetailStringForScheduleCell() -> String {
        var string = ""
        let daysKeys = daysOfTheWeek.sorted(by: { $0.key < $1.key }).map(\.key)
        daysKeys.forEach { key in
            
            if daysKeys.count == 1 {
                string += daysOfTheWeek[key]!.shortName
            }
            
            if daysKeys.count == 7 {
                string = daysOfTheWeek[0]!.everyday
            }
            
            if key != daysKeys.last && daysKeys.count != 1 && daysKeys.count != 7 {
                string += "\(daysOfTheWeek[key]!.shortName), "
            } else if daysKeys.count != 1 && daysKeys.count != 7 {
                string += daysOfTheWeek[key]!.shortName
            }
        }
        return string
    }
}
