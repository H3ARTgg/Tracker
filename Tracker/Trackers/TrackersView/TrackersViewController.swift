import UIKit

final class TrackersViewController: UIViewController {
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let headerLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let searchField = UISearchTextField()
    private var searchCancelButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var searchText: String = ""
    private var currentDate: Date = Date()
    var viewModel: TrackersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupNavigationItem()
        setupHeaderLabel()
        setupDatePicker()
        setupSearchFieldFor(searchCancel: false)
        setupCollectionView()
        
        viewModel?.$trackersCategories.bind(action: { [weak self] _ in
            self?.collectionView.reloadData()
            self?.isNeedToSetupNoContentUI()
        })
        
        isNeedToSetupNoContentUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    /// Любое взаимодействие с поиском
    @objc
    private func didInteractWithSearch() {
        let currentText = searchField.text ?? ""
        self.searchText = currentText
        viewModel?.showTrackersFor(date: currentDate, search: searchText)
    }
    
    /// Нажатие на "+"
    @objc
    private func addNewTracker() {
        resetSearchField()
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.viewModel = viewModel?.getViewModelForNewTracker()
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
    
    /// Изменение даты
    @objc
    private func didDateChanged() {
        currentDate = datePicker.date
        viewModel?.showTrackersFor(date: currentDate, search: searchText)
    }
    
    /// Нажатие на кнопку "Отменить" при поиске
    @objc
    private func didTapCancelSearchButton() {
        view.endEditing(true)
        resetSearchField()
        self.searchText = ""
        viewModel?.showTrackersFor(date: currentDate, search: searchText)
    }
    
    private func presentEditorFor(with cell: TrackersCell) {
        resetSearchField()
        let habitOrEventVC = HabitOrEventViewController()
        habitOrEventVC.viewModel = viewModel?
            .getHabitOrEventViewModel(with: cell)
        habitOrEventVC.modalPresentationStyle = .popover
        present(habitOrEventVC, animated: true)
    }
    
    /// Проверяет, нужно ли добавлять no content UI или нет.
    /// Для поиска выводит другой no content UI
    private func isNeedToSetupNoContentUI() {
        if view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        
        if viewModel?.trackersCategories.count == 0 {
            setupTitleAndImageIfNoContent(with: NSLocalizedString(.localeKeys.emptyStateTitle, comment: "Empty state title"), label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
        }
        
        if viewModel?.trackersCategories.count == 0 && searchField.isEditing {
            setupTitleAndImageIfNoContent(with: NSLocalizedString(.localeKeys.searchEmptyTitle, comment: "Search empty title"), label: noContentLabel, imageView: noContentImageView, image: UIImage(named: Constants.noResultImage)!)
        }
        
    }
    
    /// Сбрасывает поле поиска, убирает кнопку "Отменить"
    private func resetSearchField() {
        if view.subviews.contains(searchField) {
            searchCancelButton.removeFromSuperview()
            searchField.removeFromSuperview()
            setupSearchFieldFor(searchCancel: false)
            searchField.text = nil
        }
        isNeedToSetupNoContentUI()
    }
    
    /// Убирает no content UI
    private func removeNoContent() {
        noContentLabel.removeFromSuperview()
        noContentImageView.removeFromSuperview()
    }
}

// MARK: - TextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            let result = updatedText.count <= 38
            
            return result
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if searchField.text?.count == 0 {
            isNeedToSetupNoContentUI()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !view.subviews.contains(searchCancelButton) {
            setupSearchCancelButton()
        }
    }
}

// MARK: - CollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.trackersCategories.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.trackersCategories[section].trackers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackersCell else {
            assertionFailure("No TrackerListCell")
            return UICollectionViewCell(frame: .zero)
        }
        
        viewModel?.configure(cell, for: indexPath, interactionDelegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String                                      
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "Header"
        case UICollectionView.elementKindSectionFooter:
            id = "Footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else {
            assertionFailure("No SupplementaryView")
            return UICollectionReusableView(frame: .zero)
        }
        
        view.viewModel = viewModel?.trackersCategories[indexPath.section]
        
        return view
    }
}

// MARK: - CollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 4.5, height: 132)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard
            let viewModel = viewModel,
            let location = interaction.view?.convert(location, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { actions in
                let pinAction = UIAction(title: NSLocalizedString(.localeKeys.pin, comment: "")) { _ in
                    viewModel.pin(cell)
                }
                
                let unpinAction = UIAction(title: NSLocalizedString(.localeKeys.unpin, comment: "")) { _ in
                    viewModel.unpin(cell)
                }
                
                let editAction = UIAction(title: NSLocalizedString(.localeKeys.edit, comment: "")) { [weak self] _ in
                    self?.presentEditorFor(with: cell)
                }
                
                let deleteAction = UIAction(title: NSLocalizedString(.localeKeys.delete, comment: ""), attributes: .destructive) { [weak self] _ in
                    self?.setupDeleteConfirmation(cell)
                }
                
                if viewModel.isPinned(cell) {
                    return UIMenu(title: "", children: [unpinAction, editAction, deleteAction])
                } else {
                    return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
                }
            }
    }
}

// MARK: - Views Setup
extension TrackersViewController {
    private func setupHeaderLabel() {
        headerLabel.text = NSLocalizedString(.localeKeys.trackers, comment: "Trackers header")
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 41)
        ])
    }
    
    private func setupNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: Constants.plusBarItem), style: .done, target: self, action: #selector(addNewTracker))
        self.navigationItem.leftBarButtonItem?.width = 19
        self.navigationItem.leftBarButtonItem?.tintColor = .ypBlack
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.makeCornerRadius(8)
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(didDateChanged), for: .valueChanged)
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            datePicker.heightAnchor.constraint(lessThanOrEqualToConstant: 34)
        ])
    }
    
    private func setupSearchFieldFor(searchCancel: Bool) {
        searchField.placeholder = NSLocalizedString(.localeKeys.search, comment: "Search placeholder")
        searchField.backgroundColor = .searchFieldColor
        searchField.tintColor = .ypBlack
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self
        searchField.clearButtonMode = .never
        searchField.addTarget(self, action: #selector(didInteractWithSearch), for: .allEditingEvents)
        view.addSubview(searchField)
        
        if searchCancel {
            searchField.trailingAnchor.constraint(equalTo: searchCancelButton.leadingAnchor, constant: -5).isActive = true
            // Чтобы в консоли не жаловалось
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.searchField.becomeFirstResponder()
            }
        } else {
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        }
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = true
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 50),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupSearchCancelButton() {
        searchCancelButton = .systemButton(with: .xMark, target: self, action: #selector(didTapCancelSearchButton))
        
        searchCancelButton.setImage(nil, for: .normal)
        searchCancelButton.setTitle(NSLocalizedString(.localeKeys.cancel, comment: "Search cancel"), for: .normal)
        searchCancelButton.setTitleColor(.ypBlue, for: .normal)
        searchCancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchCancelButton)
        
        searchField.removeFromSuperview()
        setupSearchFieldFor(searchCancel: true)
        
        NSLayoutConstraint.activate([
            searchCancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchCancelButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor)
        ])
    }
    
    private func setupDeleteConfirmation(_ cell: TrackersCell) {
        let alert = UIAlertController(title: "", message: NSLocalizedString(.localeKeys.deleteConfirmation, comment: ""), preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString(.localeKeys.delete, comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel?.delete(cell)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString(.localeKeys.cancel, comment: ""), style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}

