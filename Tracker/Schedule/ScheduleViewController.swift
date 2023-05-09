import UIKit

final class ScheduleViewController: UIViewController {
    private let cellIdentifier = "scheduleCell"
    private let tableView = UITableView()
    private var doneButton = UIButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let daysOfTheWeekStrings = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var daysOfTheWeek: [Int: WeekDay] = [:]
    weak var delegate: ScheduleViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView)
        setupTitleLabel(with: "Расписание")
        setupTableView()
        setupDoneButton()
    }
    
    @objc
    private func didTapDoneButton() {
        delegate?.didRecieveDaysOfTheWeek(daysOfTheWeek: self.daysOfTheWeek)
        self.daysOfTheWeek.removeAll()
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerProtocol

extension ScheduleViewController: ScheduleViewControllerProtocol {
    func recieveDaysOfTheWeek(daysOfTheWeek: [Int: WeekDay]) {
        self.daysOfTheWeek = daysOfTheWeek
        tableView.reloadData()
    }
}

// MARK: - ScheduleCellDelegate

extension ScheduleViewController: ScheduleCellDelegate {
    func choiceForDay(_ check: Bool, indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            addToArray(check, for: DaysOfTheWeek.monday.rawValue, with: indexPath)
        case 1:
            addToArray(check, for: DaysOfTheWeek.tuesday.rawValue, with: indexPath)
        case 2:
            addToArray(check, for: DaysOfTheWeek.wednesday.rawValue, with: indexPath)
        case 3:
            addToArray(check, for: DaysOfTheWeek.thursday.rawValue, with: indexPath)
        case 4:
            addToArray(check, for: DaysOfTheWeek.friday.rawValue, with: indexPath)
        case 5:
            addToArray(check, for: DaysOfTheWeek.saturday.rawValue, with: indexPath)
        case 6:
            addToArray(check, for: DaysOfTheWeek.sunday.rawValue, with: indexPath)
        default:
            assertionFailure("out of cases in choiceForDay")
        }
    }
    
    private func addToArray(_ check: Bool, for dayNumber: Int, with indexPath: IndexPath) {
        if check {
            daysOfTheWeek[indexPath.row] = WeekDay(weekDay: dayNumber)
        } else {
            if daysOfTheWeek.contains(where: { dict in
                dict.value.weekDay == dayNumber
            }) {
                daysOfTheWeek.removeValue(forKey: indexPath.row)
            }
        }
    }
}

// MARK: - TableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ScheduleCell else {
            assertionFailure("No schedule cell")
            return UITableViewCell(frame: .zero)
        }
        let daysKeys = daysOfTheWeek.sorted(by: { $0.key < $1.key }).map(\.key)
        if daysKeys.contains(indexPath.row) {
            cell.setOn(true)
        }
        cell.delegate = self
        cell.setTitle(with: daysOfTheWeekStrings[indexPath.row])
        
        return cell
    }
}

// MARK: - TableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - Views

extension ScheduleViewController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.isScrollEnabled = false
        tableView.makeCornerRadius(16)
        tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        tableView.separatorColor = .ypGray
        tableView.backgroundColor = .ypWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 520),
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDoneButton() {
        doneButton = .systemButton(with: .chevronLeft, target: self, action: #selector(didTapDoneButton))
        doneButton.setImage(nil, for: .normal)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.backgroundColor = .ypBlack
        doneButton.titleLabel?.textAlignment = .center
        doneButton.makeCornerRadius(16)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
}
