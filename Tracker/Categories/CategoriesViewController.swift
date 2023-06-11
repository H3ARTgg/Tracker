import UIKit

// TODO: - Доделать под MVVM (ячейки)
final class CategoriesViewController: UIViewController {
    private let cellIdentifier = "categoriesCell"
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let tableView = UITableView()
    private var newCategoryButton = UIButton()
    var viewModel: CategoriesViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else {
            assertionFailure("no viewModel")
            return
        }
        
        if viewModel.stringCategories.isEmpty {
            setupTitleAndImageIfNoContent(with: NSLocalizedString(.localeKeys.categoryEmptyTitle, comment: "Categories empty state"), label: noContentLabel, imageView: noContentImageView, image: .noTrackers)
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupNewCategoryButton()
        setupTableView()
        setupTitleLabel(with: NSLocalizedString(.localeKeys.category, comment: "Category title"))
        
        viewModel?
            .$stringCategories.bind(action: { [weak self] _ in
                self?.removeNoContentViews()
                self?.tableView.reloadData()
        })
        
        viewModel?
            .$previousSelectedCategory.bind(action: { [weak self] indexPath in
                guard let cell = self?.tableView
                    .cellForRow(at: indexPath) as? CategoriesCell else {
                    return
                }
                cell.removeCheckmark()
        })
        
        viewModel?
            .$selectedCategory.bind(action: { [weak self] indexPath in
                guard let indexPath = indexPath else { return }
            guard let cell = self?.tableView
                .cellForRow(at: indexPath) as? CategoriesCell else {
                return
            }
            cell.setupCheckmark()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        weak var habitOrEventVC = presentingViewController as? HabitOrEventViewController
        habitOrEventVC?.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
    }
    
    @objc
    private func didTapNewCategoryButton() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.viewModel = viewModel?.getViewModelForNewCategory()
        newCategoryVC.modalPresentationStyle = .popover
        present(newCategoryVC, animated: true)
    }
    
    private func removeNoContentViews() {
        if view
            .subviews
            .contains(where: { $0 == noContentLabel }) {
            noContentLabel.removeFromSuperview()
            noContentImageView.removeFromSuperview()
            tableView.isHidden = false
        }
    }
}

// MARK: - TableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.stringCategories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CategoriesCell else {
            assertionFailure("No categoriesCell")
            return UITableViewCell(frame: .zero)
        }
        
        if let selectedCategory = viewModel?.selectedCategory {
            if indexPath.row == selectedCategory.row {
                cell.setupCheckmark()
            }
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray3
        cell.selectedBackgroundView = backgroundView
        
        guard let count = viewModel?.stringCategories.count else {
            assertionFailure("No stringCategories count")
            return cell
        }
        if indexPath.row == 0 && count > 1 {
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        cell.title.text = viewModel?.stringCategories[indexPath.row]
        
        if indexPath.row == count - 1 {
            cell.selectedBackgroundView?.makeCornerRadius(16)
            cell.contentView.makeCornerRadius(16)
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row != count - 1 && indexPath.row != 0 {
            cell.contentView.layer.cornerRadius = 0
        }
        
        return cell
    }
    
}

// MARK: - TableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            self?.viewModel?.provideCategories(selected: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - Views
extension CategoriesViewController {
    private func setupNewCategoryButton() {
        newCategoryButton = .systemButton(with: .chevronLeft, target: self, action: #selector(didTapNewCategoryButton))
        newCategoryButton.setImage(nil, for: .normal)
        newCategoryButton.setTitle(NSLocalizedString(.localeKeys.categoryAdd, comment: "Title for button that adds a new category"), for: .normal)
        newCategoryButton.setTitleColor(.ypWhite, for: .normal)
        newCategoryButton.backgroundColor = .ypBlack
        newCategoryButton.titleLabel?.textAlignment = .center
        newCategoryButton.makeCornerRadius(16)
        newCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(newCategoryButton)
        
        NSLayoutConstraint.activate([
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupTableView() {
        tableView.isScrollEnabled = true
        tableView.makeCornerRadius(16)
        tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        tableView.separatorColor = .ypGray
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -20)
        ])
    }
}
