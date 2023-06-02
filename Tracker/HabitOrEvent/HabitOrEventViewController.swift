import UIKit

final class HabitOrEventViewController: UIViewController {
    let emojiCellIdentifier = "emojiCell"
    let colorCellIdentifier = "colorCell"
    let tableViewCellIdentifier = "habitEventCell"
    let cellsStrings = ["Категория", "Расписание"]
    let contentView = UIView()
    let scrollView = UIScrollView()
    let textField = UITextField()
    let warningLabel = UILabel()
    let tableView = UITableView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let stackViewForButtons = UIStackView()
    var createButton = UIButton()
    var cancelButton = UIButton()
    var viewModel: HabitOrEventViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView, withExtraSpace: UIScreen.main.bounds.height / 3)
        scrollView.delegate = self
        setupTitleLabel(with: viewModel?.choice.rawValue ?? "")
        setupTextField()
        setupTableView()
        setupCollectionView()
        setupButtonsWithSelectorsFor(done: #selector(didTapCreate), cancel: #selector(didTapCancel), with: stackViewForButtons)
        
        viewModel?.$stringForScheduleCell.bind(action: { [weak self] text in
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? HabitOrEventCell {
                if text == self?.cellsStrings[1] {
                    if cell.contentView.subviews.count == 3 {
                        cell.removeDetailLabel()
                    }
                } else {
                    cell.detailLabelText = text
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
                assertionFailure("No cell for selected indexPath: \(indexPath)")
                return
            }
            selectedCell.deselectColor()
        })
        
        viewModel?.$oldSelectedEmojiIndex.bind(action: { [weak self] indexPath in
            guard let selectedCell = self?.collectionView.cellForItem(at: indexPath) as? HabitOrEventEmojiCell else {
                assertionFailure("No cell for selected indexPath: \(indexPath)")
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
    func didInteractionWithTextField() {
        isReadyForCreate()
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
