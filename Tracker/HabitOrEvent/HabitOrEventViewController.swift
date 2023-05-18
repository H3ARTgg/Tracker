import UIKit

protocol HabitOrEventDelegate: AnyObject {
    var stringCategories: [String] { get }
    func didRecieveTracker(_ tracker: Tracker, forCategoryTitle category: String) throws
}

final class HabitOrEventViewController: UIViewController {
    private var trackersVC: TrackersViewController?
    private weak var delegate: HabitOrEventDelegate?
    private (set) var stringCategories: [String] = []
    private (set) var daysOfTheWeek: [Int: WeekDay] = [:]
    private (set) var choice: Choice!
    let emojiCellIdentifier = "emojiCell"
    let colorCellIdentifier = "colorCell"
    let tableViewCellIdentifier = "habitEventCell"
    let cellsStrings: [String] = ["Категория", "Расписание"]
    let contentView = UIView()
    let scrollView = UIScrollView()
    let textField = UITextField()
    let warningLabel = UILabel()
    let tableView = UITableView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let stackViewForButtons = UIStackView()
    var createButton = UIButton()
    var cancelButton = UIButton()
    var selectedEmoji: IndexPath?
    var selectedColor: IndexPath?
    var selectedCategory: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        if let categories = delegate?.stringCategories {
            self.stringCategories = categories
        }
        
        setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView, withExtraSpace: UIScreen.main.bounds.height / 3)
        scrollView.delegate = self
        setupTitleLabel(with: self.choice.rawValue)
        setupTextField()
        setupTableView()
        setupCollectionView()
        setupButtonsWithSelectorsFor(done: #selector(didTapCreate), cancel: #selector(didTapCancel), with: stackViewForButtons)
    }
    
    required init(choice: Choice, delegate: HabitOrEventDelegate) {
        super.init(nibName: .none, bundle: .none)
        self.choice = choice
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTapCancel() {
        weak var presentingVC = self.presentingViewController
        dismiss(animated: true)
        presentingVC?.dismiss(animated: true)
    }
    
    @objc
    private func didTapCreate() {
        if
            let selectedEmoji = selectedEmoji,
            let selectedColor = selectedColor,
            let selectedCategory = selectedCategory,
            let text = textField.text,
            textField.text?.count != 0 {
            
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
            try? delegate?.didRecieveTracker(tracker, forCategoryTitle: stringCategories[selectedCategory.row])
            
            weak var presentingVC = self.presentingViewController
            dismiss(animated: true)
            presentingVC?.dismiss(animated: true)
        }
    }
    
    @objc
    func didInteractionWithTextField() {
        isReadyForCreate()
    }
    
    func isReadyForCreate() {
        if
            let _ = selectedEmoji,
            let _ = selectedColor,
            let _ = selectedCategory,
            let text = textField.text,
            text.count != 0 {
            switch choice {
            case .habit:
                if !daysOfTheWeek.isEmpty {
                    activateCreateButton()
                } else {
                    deactivateCreateButton()
                }
            case .event:
                activateCreateButton()
            case .none:
                assertionFailure("out of choice cases")
            }
        } else {
            deactivateCreateButton()
        }
    }
    
    private func deactivateCreateButton() {
        createButton.backgroundColor = .ypGray
        createButton.setTitleColor(.ypBlack, for: .normal)
        createButton.isUserInteractionEnabled = false
    }
    
    private func activateCreateButton() {
        createButton.backgroundColor = .ypBlack
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.isUserInteractionEnabled = true
    }
}

// MARK: - CategoriesViewControllerDelegate

extension HabitOrEventViewController: CategoriesViewControllerDelegate {
    func selectedCategory(indexPath: IndexPath, categories: [String]) {
        self.stringCategories = categories
        selectedCategory = indexPath
        isReadyForCreate()
        
        let cellIndexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.cellForRow(at: cellIndexPath) as? HabitOrEventCell else {
            assertionFailure("No cell for that indexPath")
            return
        }
        
        if stringCategories.count > 0 {
            cell.detailLabelText = stringCategories[indexPath.row]
        }
        tableView.reloadData()
    }
}

// MARK: - ScheduleViewControllerDelegate

extension HabitOrEventViewController: ScheduleViewControllerDelegate {
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [Int: WeekDay]) {
        self.daysOfTheWeek.removeAll()
        self.daysOfTheWeek = daysOfTheWeek
        isReadyForCreate()
        
        let cellIndexPath = IndexPath(row: 1, section: 0)
        guard let cell = tableView.cellForRow(at: cellIndexPath) as? HabitOrEventCell else {
            assertionFailure("No cell for that indexPath")
            return
        }
        if daysOfTheWeek.count > 0 {
            let string = makeDetailStringForScheduleCell()
            cell.detailLabelText = string
        } else if daysOfTheWeek.isEmpty {
            if cell.contentView.subviews.count == 3 {
                cell.removeDetailLabel()
                tableView.reloadData()
            }
        }
        tableView.reloadData()
    }
    
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

// MARK: - TextFieldDelegate

extension HabitOrEventViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            let result = updatedText.count <= 38
            if result {
                if contentView.subviews.contains(where: { $0 == warningLabel }) {
                    warningLabel.removeFromSuperview()
                    tableView.removeFromSuperview()
                    setupTableView()
                }
            } else {
                tableView.removeFromSuperview()
                setupWarningLabel()
                setupTableView()
            }
            return result
        }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = nil
        isReadyForCreate()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
        isReadyForCreate()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if contentView.subviews.contains(where: { $0 == warningLabel }) {
            warningLabel.removeFromSuperview()
            tableView.removeFromSuperview()
            setupTableView()
        }
        isReadyForCreate()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isReadyForCreate()
        return true
    }
}

// MARK: - ScrollViewDelegate

extension HabitOrEventViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
        isReadyForCreate()
    }
}
