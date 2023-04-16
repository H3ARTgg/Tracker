import UIKit

final class HabitOrEventViewController: UIViewController {
    private var choice: Choice!
    private var textField = UITextField()
    private let warningLabel = UILabel()
    private let tableView = UITableView()
    private let cellsStrings: [String] = ["Категория", "Расписание"]
    private var stringCategories: [String] = []
    private var selectedCategory: IndexPath?
    private var daysOfTheWeek: [Int: DaysOfTheWeek] = [:]
    private let stringsDaysOfTheWeek: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс", "Каждый день"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let trackersVC = getTrackersViewController() as? TrackersViewController else {
            assertionFailure("No trackersVC")
            return
        }
        
        for category in trackersVC.categories {
            stringCategories.append(category.title)
        }
        
        view.backgroundColor = .ypWhite
        setupTitleLabel(with: self.choice.rawValue)
        setupTextField()
        setupTableView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    required init(choice: Choice) {
        super.init(nibName: .none, bundle: .none)
        self.choice = choice
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTapCancel() {
        stringCategories.removeAll()
        daysOfTheWeek.removeAll()
    }
}

// MARK: - CategoriesViewControllerDelegate

extension HabitOrEventViewController: CategoriesViewControllerDelegate {
    func selectedCategory(indexPath: IndexPath, categories: [String]) {
        self.stringCategories = categories
        selectedCategory = indexPath
        
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
    func didRecieveDaysOfTheWeek(daysOfTheWeek: [Int: DaysOfTheWeek]) {
        self.daysOfTheWeek.removeAll()
        self.daysOfTheWeek = daysOfTheWeek
        
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
        daysKeys.forEach { [weak self] key in
            guard let self = self else { return }
            
            if daysKeys.count == 1 {
                string += self.stringsDaysOfTheWeek[key]
            }
            
            if daysKeys.count == 7 {
                string = self.stringsDaysOfTheWeek[7]
            }
            
            if key != daysKeys.last && daysKeys.count != 1 && daysKeys.count != 7 {
                string += "\(self.stringsDaysOfTheWeek[key]), "
            } else if daysKeys.count != 1 && daysKeys.count != 7 {
                string += self.stringsDaysOfTheWeek[key]
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
                if view.subviews.contains(where: { $0 == warningLabel }) {
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if view.subviews.contains(where: { $0 == warningLabel }) {
            warningLabel.removeFromSuperview()
            tableView.removeFromSuperview()
            setupTableView()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - TableViewDataSource

extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch choice {
        case .habit:
            return 2
        case .event:
            return 1
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "habitEventCell", for: indexPath) as? HabitOrEventCell else {
            assertionFailure("No habitEventCell")
            return UITableViewCell(frame: .zero)
        }
        
        cell.title.text = cellsStrings[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
}

// MARK: - TableViewDelegate

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
        present(categoriesVC, animated: true)
    }
    
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.modalPresentationStyle = .popover
        scheduleVC.delegate = self
        scheduleVC.recieveDaysOfTheWeek(daysOfTheWeek: self.daysOfTheWeek)
        present(scheduleVC, animated: true)
    }
}

// MARK: - Views

extension HabitOrEventViewController {
    private func setupTextField() {
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
        textField.setPaddingFor(left: 16)
        textField.clearButtonMode = .always
        textField.backgroundColor = .ypBackground
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.makeCornerRadius(16)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupWarningLabel() {
        warningLabel.font = .systemFont(ofSize: 17, weight: .regular)
        warningLabel.text = "Ограничение 38 символов"
        warningLabel.textColor = .ypRed
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.makeCornerRadius(16)
        tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        tableView.separatorColor = .ypGray
        tableView.register(HabitOrEventCell.self, forCellReuseIdentifier: "habitEventCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        switch choice {
        case .habit:
            tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        case .event:
            tableView.heightAnchor.constraint(equalToConstant: 73).isActive = true
        case .none:
            tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        }
        
        if view.subviews.contains(where: {$0 == warningLabel}) {
            tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 32).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24).isActive = true
        }
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
