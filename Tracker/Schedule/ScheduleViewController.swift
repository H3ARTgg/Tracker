import UIKit

// TODO: Переделать под MVVM
final class ScheduleViewController: UIViewController {
    private let cellIdentifier = "scheduleCell"
    private let tableView = UITableView()
    private var doneButton = UIButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var daysOfTheWeek: [WeekDay] = []
    weak var delegate: ScheduleViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupScrollViewAndContentView(scrollView: scrollView, contentView: contentView)
        setupTitleLabel(with: NSLocalizedString(.localeKeys.schedule, comment: "Schedule title"))
        setupTableView()
        setupDoneButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        weak var habitOrEventVC = presentingViewController as? HabitOrEventViewController
        habitOrEventVC?.tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: true)
    }
    
    @objc
    private func didTapDoneButton() {
        delegate?.didRecieveDaysOfTheWeek(daysOfTheWeek: self.daysOfTheWeek
            .sorted(by: { $0.weekDay < $1.weekDay }))
        self.daysOfTheWeek.removeAll()
        dismiss(animated: true)
    }
}

// MARK: - ScheduleViewControllerProtocols
extension ScheduleViewController: ScheduleViewControllerProtocol {
    func recieveDaysOfTheWeek(daysOfTheWeek: [WeekDay]) {
        self.daysOfTheWeek = daysOfTheWeek
        tableView.reloadData()
    }
}

// MARK: - ScheduleCellDelegate
extension ScheduleViewController: ScheduleCellDelegate {
    func choiceForDay(_ isSwitherOn: Bool, indexPath: IndexPath) {
        if isSwitherOn {
            daysOfTheWeek.append(WeekDay(cellRow: indexPath.row))
        } else {
            daysOfTheWeek.removeAll { $0.cellRow == indexPath.row }
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

        if daysOfTheWeek.contains(where: { $0.cellRow == indexPath.row }) {
            cell.setOn(true)
        }
        cell.delegate = self
        let weekDay = WeekDay(cellRow: indexPath.row)
        cell.setTitle(with: weekDay.longNameForCell)
        
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
        doneButton.setTitle(NSLocalizedString(.localeKeys.done, comment: "Title for done button"), for: .normal)
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
