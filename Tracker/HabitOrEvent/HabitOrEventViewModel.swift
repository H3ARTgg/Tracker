import Foundation
import UIKit

protocol HabitOrEventDelegate: AnyObject {
    var stringCategories: [String] { get }
    func didRecieveTracker(_ tracker: Tracker, category: String, allCategories: [String], recordCount: Int?) throws
}

final class HabitOrEventViewModel {
    private var id: UUID?
    private var nameOfTracker: String?
    private var selectedEmoji: IndexPath?
    private var selectedColor: IndexPath?
    private(set) var daysOfTheWeek: [WeekDay] = []
    private(set) var recordCount: Int = -1 {
        didSet {
            recordText = String.localizedStringWithFormat(
                NSLocalizedString(.localeKeys.numberOfDays, comment: ""), recordCount
            )
        }
    }
    private(set) var isEditing: Bool?
    private(set) var colorForEditButtons = UIColor.black
    @Observable private(set) var oldSelectedEmojiIndex = IndexPath(row: 0, section: 0)
    @Observable private(set) var oldSelectedColorIndex = IndexPath(row: 0, section: 1)
    @Observable private(set) var stringCategories: [String] = []
    @Observable private(set) var selectedCategory: String?
    @Observable private(set) var stringForScheduleCell: String?
    @Observable private(set) var recordText: String?
    let choice: Choice
    let delegate: HabitOrEventDelegate
    
    init(
        choice: Choice,
        delegate: HabitOrEventDelegate,
        trackerEdit: TrackerEdit? = nil
    ) {
        self.choice = choice
        self.delegate = delegate
        self.stringCategories = delegate.stringCategories
        
        if let trackerEdit = trackerEdit {
            let emojiIndex = String.emojisArray.firstIndex(of: trackerEdit.trackerCategory.trackers[0].emoji)
            var colorIndex: Int = 0
            for (i, color) in UIColor.selectionColors.enumerated() {
                guard let color = color else { continue }
                if ColorMarshalling.compare(color, trackerEdit.trackerCategory.trackers[0].color) {
                    colorIndex = i
                }
            }
            
            isEditing = true
            id = trackerEdit.trackerCategory.trackers[0].id
            recordCount = trackerEdit.recordCount
            recordText = String.localizedStringWithFormat(
                NSLocalizedString(.localeKeys.numberOfDays, comment: ""), recordCount
            )
            selectedCategory = trackerEdit.trackerCategory.title
            selectedEmoji = IndexPath(row: emojiIndex ?? 0, section: 0)
            selectedColor = IndexPath(row: colorIndex, section: 1)
            colorForEditButtons = trackerEdit.trackerCategory.trackers[0].color
            nameOfTracker = trackerEdit.trackerCategory.trackers[0].name
            
            if let weekDays = trackerEdit
                .trackerCategory
                .trackers[0]
                .daysOfTheWeek {
                daysOfTheWeek = weekDays
                stringForScheduleCell = makeDetailStringForScheduleCell(weekDays)
            }
        }
    }
    
    /// Возвращает имя трекера, если оно есть (при редактировании)
    func getNameOfTracker() -> String {
        if let nameOfTracker = nameOfTracker {
            return nameOfTracker
        } else {
            return ""
        }
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
            if case .habit = choice {
                if daysOfTheWeek.count != 0 {
                    daysValues = daysOfTheWeek
                }
            }
            
            let tracker = Tracker(
                id: id ?? UUID(),
                name: text,
                color: UIColor.selectionColors[selectedColor.row] ?? .white,
                emoji: String.emojisArray[selectedEmoji.row],
                daysOfTheWeek: daysValues ?? nil,
                createdAt: Date()
            )
            if recordCount != -1 {
                try? delegate.didRecieveTracker(tracker, category: selectedCategory, allCategories: self.stringCategories, recordCount: recordCount)
            } else {
                try? delegate.didRecieveTracker(tracker, category: selectedCategory, allCategories: self.stringCategories, recordCount: nil)
            }
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
            case .edit(let choice):
                switch choice {
                case .habit:
                    if !daysOfTheWeek.isEmpty {
                        return true
                    } else {
                        return false
                    }
                case .event:
                    return true
                default:
                    return false
                }
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
        colorForEditButtons = UIColor.selectionColors[indexPath.row] ?? UIColor.black
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
    
    func configure(_ cell: HabitOrEventEmojiCell, with indexPath: IndexPath) {
        cell.emoji.text = String.emojisArray[indexPath.row]
        if indexPath == selectedEmoji {
            cell.selectEmoji()
            selectEmoji(at: indexPath)
        }
    }
    
    func configure(_ cell: HabitOrEventColorCell, with indexPath: IndexPath) {
        cell.colorView.backgroundColor = UIColor.selectionColors[indexPath.row]
        if indexPath == selectedColor {
            cell.selectColor()
            selectColor(at: indexPath)
        }
    }
    
    func increaseRecordCount() {
        recordCount += 1
    }
    
    func decreaseRecordCount() {
        if recordCount <= 0 {
            return
        } else {
            recordCount -= 1
        }
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
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [WeekDay]) {
        self.daysOfTheWeek.removeAll()
        self.daysOfTheWeek = daysOfTheWeek
        
        if daysOfTheWeek.count > 0 {
            stringForScheduleCell = makeDetailStringForScheduleCell(daysOfTheWeek)
        } else if daysOfTheWeek.isEmpty {
            stringForScheduleCell = nil
        }
    }
    
    /// Возвращает дополнительный текст для обозначения выбранных дней недели для ячейки
    private func makeDetailStringForScheduleCell(_ weekDays: [WeekDay]) -> String {
        var string = ""
        weekDays.forEach { weekDay in
            if weekDays.count == 1 {
                string += weekDay.shortName
            }
            
            if weekDays.count == 7 {
                string = weekDay.everyday
            }
            
            guard let last = weekDays.last else { return }
            if weekDay.cellRow != last.cellRow && weekDays.count != 7 {
                string += "\(weekDay.shortName), "
            } else if weekDays.count != 1 && weekDays.count != 7 {
                string += weekDay.shortName
            }
        }
        return string
    }
}
