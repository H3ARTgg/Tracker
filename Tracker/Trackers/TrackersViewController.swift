import UIKit

final class TrackersViewController: UIViewController, NewTrackerDelegate {
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let headerLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let searchField = UISearchTextField()
    private var searchCancelButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var stringCategories: [String]? {
        get {
            do {
                return try trackerCategoryStore.getAllCategoriesTitles()
            } catch {
                return []
            }
        }
    }
    private var currentDate: Date = Date()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let uiColorMarshalling = UIColorMarshalling()
    private var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupNavigationItem()
        setupHeaderLabel()
        setupDatePicker()
        setupSearchFieldFor(searchCancel: false)
        setupCollectionView()
        
        try? trackerStore.showTrackersByDayOfTheWeekFor(date: currentDate, searchText: searchText)
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
        try? trackerStore.showTrackersByDayOfTheWeekFor(date: currentDate, searchText: searchText)
        isNeedToSetupNoContentUI()
        collectionView.reloadData()
    }
    
    /// Нажатие на "+"
    @objc
    private func addNewTracker() {
        resetSearchField()
        let newTrackerVC = NewTrackerViewController(delegate: self)
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
    
    /// Изменение даты
    @objc
    private func didDateChanged() {
        currentDate = datePicker.date
        try? trackerStore.showTrackersByDayOfTheWeekFor(date: currentDate, searchText: searchText)
        collectionView.reloadData()
    }
    
    /// Нажатие на кнопку "Отменить" при поиске
    @objc
    private func didTapCancelSearchButton() {
        view.endEditing(true)
        resetSearchField()
        self.searchText = ""
        try? trackerStore.showTrackersByDayOfTheWeekFor(date: currentDate, searchText: searchText)
        isNeedToSetupNoContentUI()
    }
    
    /// Проверяет, нужно ли добавлять no content UI или нет.
    /// Для поиска выводит другой no content UI
    private func isNeedToSetupNoContentUI() {
        if view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        
        let categories = try? trackerCategoryStore.getAllCategoriesTitles()
        
        if categories == nil {
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
        }
        
        if categories != nil && trackerStore.numberOfSections == 0 {
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
        }
        
        if trackerStore.numberOfFetchedCategories() == 0 && categories != nil {
            setupTitleAndImageIfNoContent(with: "Ничего не найдено", label: noContentLabel, imageView: noContentImageView, image: UIImage(named: Constants.noResultImage)!)
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

// MARK: - TrackersCellDelegate
extension TrackersViewController: TrackersCellDelegate {
    func didRecieveNewRecord(_ completed: Bool, for id: UUID) {
        let newRecord = TrackerRecord(id: id, date: currentDate)
        if completed {
            let newRecord = TrackerRecord(id: id, date: currentDate)
            try? trackerRecordStore.addTrackerRecord(newRecord)
        } else {
            try? trackerRecordStore.deleteTrackerRecord(newRecord, for: currentDate)
        }
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

// MARK: - HabitOrEventDelegate
extension TrackersViewController: HabitOrEventDelegate {
    func didRecieveTracker(_ tracker: Tracker, forCategoryTitle category: String) throws {
        let newTrackerCategory = TrackerCategory(title: category, trackers: [tracker], createdAt: Date())
        
        let isTrackerExists = trackerStore.checkForExisting(tracker: tracker)
        if isTrackerExists {
            let existingTracker = try trackerStore.getCDTracker(tracker: tracker)
            let existingCategory = try trackerCategoryStore.getCDTrackerCategoryFor(title: category)
            trackerStore.updateExistingTracker(existingTracker, with: tracker, for: existingCategory)
        } else {
            let isCategoryExist = trackerCategoryStore.checkForExisting(categoryTitle: category)
            if isCategoryExist {
                try trackerStore.addNewTracker(tracker, forCategoryTitle: category)
            } else {
                trackerCategoryStore.addNewTrackerCategory(newTrackerCategory)
                try trackerStore.addNewTracker(tracker, forCategoryTitle: category)
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate() {
        collectionView.reloadData()
    }
}

// MARK: - CollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackersCell else {
            assertionFailure("No TrackerListCell")
            return UICollectionViewCell(frame: .zero)
        }
        /// Убеждаемся, что такой трекер есть. А если он есть, то можно использовать force unwrap для его свойств, так как они не опциональны
        guard let tracker = trackerStore.object(at: indexPath) else {
            return UICollectionViewCell(frame: .zero)
        }
        
        let isRecordExists = trackerRecordStore.isRecordExistsFor(trackerID: tracker.id!, and: currentDate)
        let daysCount = trackerRecordStore.recordsCountFor(trackerID: tracker.id!)
        
        cell.configCell(
            delegate: self,
            id: tracker.id!,
            color: uiColorMarshalling.color(from: tracker.colorHex!),
            trackerName: tracker.name!,
            emoji: tracker.emoji!,
            daysCount: daysCount,
            isRecordExists: isRecordExists,
            currentDate: currentDate,
            indexPath: indexPath)
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
        let category = trackerStore.object(at: indexPath)?.category
        view.titleLabel.text = category?.title
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
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

// MARK: - Views Setup
extension TrackersViewController {
    private func setupHeaderLabel() {
        headerLabel.text = "Трекеры"
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
        datePicker.locale = Locale(identifier: "ru")
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
        searchField.placeholder = "Поиск"
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
        searchCancelButton.setTitle("Отменить", for: .normal)
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
}

