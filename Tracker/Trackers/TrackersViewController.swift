import UIKit

final class TrackersViewController: UIViewController {
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let headerLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let searchField = UISearchTextField()
    private var searchCancelButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackersIds: Set<UInt> = []
    private var currentDate: Date = Date()
    private (set) var categories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        isCategoriesEmpty()
        setupNavigationItem()
        setupHeaderLabel()
        setupDatePicker()
        setupSearchFieldFor(searchCancel: false)
        setupCollectionView()
        showTrackersForCurrentDate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func isCategoriesEmpty() {
        if view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        
        if categories.isEmpty {
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
        }
        
        if !categories.isEmpty && visibleCategories.isEmpty {
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
        }
    }
    
    @objc
    private func didInteractWithSearch() {
        let currentText = searchField.text ?? ""
        
        if currentText.count > 0 {
            showSearchResultFor(currentText)
        } else {
            showTrackersForCurrentDate()
        }
    }
    
    @objc
    private func addNewTracker() {
        resetSearchField()
        showTrackersForCurrentDate()
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
    
    @objc
    private func didDateChanged() {
        currentDate = datePicker.date
        showTrackersForCurrentDate()
    }
    
    @objc
    private func didTapCancelSearchButton() {
        view.endEditing(true)
        resetSearchField()
        isCategoriesEmpty()
        showTrackersForCurrentDate()
    }
    
    private func resetSearchField() {
        if view.subviews.contains(searchField) {
            searchCancelButton.removeFromSuperview()
            searchField.removeFromSuperview()
            setupSearchFieldFor(searchCancel: false)
            searchField.text = nil
        }
        isCategoriesEmpty()
    }
    
    private func removeNoContent() {
        noContentLabel.removeFromSuperview()
        noContentImageView.removeFromSuperview()
    }
    
    private func showTrackersForCurrentDate() {
        visibleCategories.removeAll()
        var categoriesForCurrentDate: [TrackerCategory] = []
        let weekDay = currentDate.weekDay()
        categories.forEach { category in
            var rightTrackers: [Tracker] = []
            category.trackers.forEach { [weak self] tracker in
                guard let self = self else { return }
                
                if let daysOfTheWeek = tracker.daysOfTheWeek {
                    daysOfTheWeek.forEach {
                        $0.rawValue == weekDay ? rightTrackers.append(tracker) : nil
                    }
                } else {
                    tracker.date.hasSame([.day, .month, .year], as: self.currentDate) ? rightTrackers.append(tracker) : nil
                }
            }
            if rightTrackers.count != 0 {
                let newCategory = TrackerCategory(title: category.title, trackers: rightTrackers)
                categoriesForCurrentDate.append(newCategory)
            }
        }
        
        if categoriesForCurrentDate.count == 0 {
            isCategoriesEmpty()
        } else if categoriesForCurrentDate.count != 0 && view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        visibleCategories = categoriesForCurrentDate
        collectionView.reloadData()
    }
    
    private func showSearchResultFor(_ text: String) {
        var categoriesForCurrentSearch: [TrackerCategory] = []
        categories.forEach { category in
            var rightTrackers: [Tracker] = []
            for tracker in category.trackers where tracker.name.contains(text) {
                rightTrackers.append(tracker)
            }
            
            if rightTrackers.count != 0 {
                let newCategory = TrackerCategory(title: category.title, trackers: rightTrackers)
                categoriesForCurrentSearch.append(newCategory)
            }
        }
        
        if categoriesForCurrentSearch.count == 0 {
            setupTitleAndImageIfNoContent(with: "Ничего не найдено", label: noContentLabel, imageView: noContentImageView, image: .noResult)
        } else if categoriesForCurrentSearch.count != 0 && view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        collectionView.reloadData()
        visibleCategories = categoriesForCurrentSearch
    }
    
    func didReceiveCategories(categories: [TrackerCategory]) {
        self.categories = categories
        showTrackersForCurrentDate()
        isCategoriesEmpty()
        collectionView.reloadData()
    }
}

// MARK: - TrackersCellDelegate

extension TrackersViewController: TrackersCellDelegate {
    func didRecieveNewRecord(_ completed: Bool, for id: UInt) {
        if completed {
            let newRecord = TrackerRecord(id: id, date: currentDate)
            completedTrackers.append(newRecord)
            completedTrackersIds.insert(id)
        } else {
            completedTrackers.removeAll { $0.date.hasSame([.day, .month, .year], as: currentDate) }
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
            isCategoriesEmpty()
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        for number in 0..<visibleCategories.count {
            if number == section {
                return visibleCategories[number].trackers.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackersCell else {
            assertionFailure("No TrackerListCell")
            return UICollectionViewCell(frame: .zero)
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        var isSameDate: Bool = false
        var daysCount = 0
        if completedTrackersIds.contains(tracker.id) {
            let completedDays = completedTrackers.filter { $0.id == tracker.id }
            let completedDaysCount = completedDays.count
            daysCount = completedDaysCount
            if completedDays.contains(where: { [weak self] in
                guard let self = self else { return false }
                return $0.date.hasSame([.day, .month, .year], as: self.currentDate)
            }) {
                isSameDate = true
            }
        }
        
        cell.configCell(
            delegate: self,
            id: tracker.id,
            color: tracker.color,
            trackerName: tracker.name,
            emoji: tracker.emoji,
            daysCount: daysCount,
            isSameDate: isSameDate,
            currentDate: currentDate)
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
        view.titleLabel.text = categories[indexPath.section].title
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
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
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 77),
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

