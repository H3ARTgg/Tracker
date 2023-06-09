import UIKit

// TODO: - Доделать под MVVM (ячейки)
final class HabitOrEventViewController: UIViewController {
    let emojiCellIdentifier = "emojiCell"
    let colorCellIdentifier = "colorCell"
    let tableViewCellIdentifier = "habitEventCell"
    let contentView = UIView()
    let scrollView = UIScrollView()
    let textField = UITextField()
    let warningLabel = UILabel()
    let tableView = UITableView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let stackViewForButtons = UIStackView()
    let stackViewForEdit = UIStackView()
    let editRecordLabel = UILabel()
    var createButton = UIButton()
    var cancelButton = UIButton()
    var editMinusButton = UIButton()
    var editPlusButton = UIButton()
    var viewModel: HabitOrEventViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        if let isEditing = viewModel?.isEditing {
            setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView, withExtraSpace: UIScreen.main.bounds.height / 3, isEditing: isEditing)
            setupRecordEditing(
                with: viewModel?.recordText ?? "",
                minusAction: #selector(didTapMinus),
                plusAction: #selector(didTapPlus)
            )
        } else {
            setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView, withExtraSpace: UIScreen.main.bounds.height / 3)
        }
        scrollView.delegate = self
        
        setupTitleLabel(with: makeTitleTextByChoice())
        setupTextField()
        setupTableView()
        setupCollectionView()
        setupButtonsWithSelectorsFor(done: #selector(didTapCreate), cancel: #selector(didTapCancel), with: stackViewForButtons)
        setupBinds()
        
        if case .edit(_) = viewModel?.choice {
            textField.text = viewModel?.getNameOfTracker()
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: IndexPath(row: 0, section: 0)) as? HabitOrEventCell else {
                assertionFailure("No habitEventCell")
                return
            }
            cell.detailLabelText = viewModel?.selectedCategory ?? ""
            isReadyForCreate()
        }
    }
    
    @objc
    private func didTapCancel() {
        weak var presentingVC = self.presentingViewController
        dismiss(animated: true)
        presentingVC?.dismiss(animated: true)
    }
    
    @objc
    private func didTapCreate() {
        viewModel?.didTapCreateButton(text: textField.text)
        weak var presentingVC = self.presentingViewController
        dismiss(animated: true)
        presentingVC?.dismiss(animated: true)
    }
    
    @objc
    private func didTapPlus() {
        viewModel?.increaseRecordCount()
    }
    
    @objc
    private func didTapMinus() {
        viewModel?.decreaseRecordCount()
    }
    
    @objc
    func didInteractionWithTextField() {
        isReadyForCreate()
    }
    
    private func makeTitleTextByChoice() -> String {
        switch viewModel?.choice {
        case .habit:
            return NSLocalizedString(.localeKeys.habitNew, comment: "ViewController title for new habit")
        case .event:
            return NSLocalizedString(.localeKeys.eventNew, comment: "ViewController title for new irregular event")
        case .edit(let choice):
            switch choice {
            case .habit:
                return NSLocalizedString(.localeKeys.habitEdit, comment: "")
            case .event:
                return NSLocalizedString(.localeKeys.eventEdit, comment: "")
            default:
                return ""
            }
        default:
            return ""
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
    
    private func setupBinds() {
        viewModel?.$stringForScheduleCell.bind(action: { [weak self] text in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? HabitOrEventCell {
                if let text = text {
                    cell.detailLabelText = text
                } else {
                    cell.removeDetailLabel()
                }
            }
            self?.isReadyForCreate()
            self?.tableView.reloadData()
        })
        
        viewModel?.$stringCategories.bind(action: { [weak self] _ in
            self?.isReadyForCreate()
            self?.tableView.reloadData()
        })
        
        viewModel?.$oldSelectedColorIndex.bind(action: { [weak self] indexPath in
            guard let selectedCell = self?.collectionView.cellForItem(at: indexPath) as? HabitOrEventColorCell else {
                return
            }
            selectedCell.deselectColor()
        })
        
        viewModel?.$oldSelectedEmojiIndex.bind(action: { [weak self] indexPath in
            guard let selectedCell = self?.collectionView.cellForItem(at: indexPath) as? HabitOrEventEmojiCell else {
                return
            }
            selectedCell.deselectEmoji()
        })
        
        viewModel?.$selectedCategory.bind(action: {[weak self] text in
            if let text = text {
                guard let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HabitOrEventCell else { return }
                cell.detailLabelText = text
            }
        })
        
        viewModel?.$recordText.bind(action: { [weak self] text in
            self?.editRecordLabel.text = text
        })
    }
    
    func isReadyForCreate() {
        guard let check = viewModel?.isReadyForCreate(text: textField.text) else {
            return
        }
        
        if check {
            activateCreateButton()
        } else {
            deactivateCreateButton()
        }
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
            string: NSLocalizedString(.localeKeys.typeTrackerTitle, comment: ""),
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
