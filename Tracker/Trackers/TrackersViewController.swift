import UIKit
protocol TrackersProtocol {
    var categories: [TrackerCategory] { get set }
}

final class TrackersViewController: UIViewController, TrackersProtocol {
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let headerLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let searchField = UISearchTextField()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    // TODO: - Реализовать нажатие на плюсик и TrackerRecord, а также невозможность "отметить карточку для будущей даты"
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackersIds: Set<UInt> = []
    private var currentDate: Date = Date()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if categories.isEmpty {
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupNavigationItem()
        setupHeaderLabel()
        setupDatePicker()
        setupSearchField()
        setupCollectionView()
    }
    
    @objc
    private func addNewTracker() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
    
    @objc
    private func didDateChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
    }
    
    private func removeNoContent() {
        noContentLabel.removeFromSuperview()
        noContentImageView.removeFromSuperview()
    }
    
    private func showTrackersForCurrentDate() {
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
            setupTitleAndImageIfNoContent(with: "Что будем отслеживать?", label: noContentLabel, imageView: noContentImageView)
        } else if categoriesForCurrentDate.count != 0 && view.subviews.contains(noContentLabel) {
            removeNoContent()
        }
        visibleCategories = categoriesForCurrentDate
    }
    
    func didReceiveCategories(categories: [TrackerCategory]) {
        self.categories = categories
        removeNoContent()
        collectionView.reloadData()
    }
}

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
        
        cell.selectionColor = visibleCategories[indexPath.section].trackers[indexPath.row].color
        cell.cardText.text = visibleCategories[indexPath.section].trackers[indexPath.row].name
        cell.cardEmoji.text = visibleCategories[indexPath.section].trackers[indexPath.row].emoji
        cell.daysLabel.text = "0 дней"
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
        showTrackersForCurrentDate()
        return visibleCategories.count
    }
}

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
    
    private func setupSearchField() {
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = .searchFieldColor
        searchField.tintColor = .ypBlack
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

