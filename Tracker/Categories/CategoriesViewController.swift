import UIKit

final class CategoriesViewController: UIViewController {
    private let cellIdentifier = "categoriesCell"
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    private let tableView = UITableView()
    private var newCategoryButton = UIButton()
    private var lastAmount: CGFloat!
    private var stringCategories: [String] = []
    private var selectedCategory: IndexPath?
    weak var delegate: CategoriesViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if stringCategories.isEmpty {
            setupTitleAndImageIfNoContent(with: "Привычки и события можно объединить по смыслу", label: noContentLabel, imageView: noContentImageView)
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTableView()
        setupTitleLabel(with: "Категория")
        setupNewCategoryButton()
    }
    
    @objc
    private func didTapNewCategoryButton() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.modalPresentationStyle = .popover
        present(newCategoryVC, animated: true)
    }
    
    private func removeNoContentViews() {
        noContentLabel.removeFromSuperview()
        noContentImageView.removeFromSuperview()
        tableView.isHidden = false

        tableView.removeFromSuperview()
        setupTableView()
        tableView.reloadData()
    }
    
    func addNewCategory(category: String) {
        if stringCategories.isEmpty {
            removeNoContentViews()
        }
        if stringCategories.contains(category) {
            return
        }
        self.stringCategories.append(category)
        reloadCurrentCheckmarkForLastCreatedCategory()
        tableView.removeFromSuperview()
        setupTableView()
        tableView.reloadData()
    }
    
    private func reloadCurrentCheckmarkForLastCreatedCategory() {
        if let selectedCategory = selectedCategory {
            guard let cell = tableView.cellForRow(at: selectedCategory) as? CategoriesCell else {
                assertionFailure("No cell for that IndexPath: \(selectedCategory)")
                return
            }
            cell.removeCheckmark()
        }
        let lastCreatedCategory = IndexPath(row: stringCategories.count - 1, section: 0)
        self.selectedCategory = lastCreatedCategory
    }
    
}

// MARK: - CategoriesViewControllerProtocol

extension CategoriesViewController: CategoriesViewControllerProtocol {
    func recieveCategories(categories: [String], currentAt: IndexPath?) {
        self.stringCategories = categories
        self.selectedCategory = currentAt
        tableView.reloadData()
    }
}

// MARK: - TableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stringCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CategoriesCell else {
            assertionFailure("No categoriesCell")
            return UITableViewCell(frame: .zero)
        }
        
        if let selectedCategory = selectedCategory {
            if indexPath.row == selectedCategory.row {
                cell.setupCheckmark()
            }
        }
        
        cell.title.text = stringCategories[indexPath.row]
        
        return cell
    }
    
}

// MARK: - TableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        weak var habitOrEventVC = self.presentingViewController as? HabitOrEventViewController
        habitOrEventVC?.selectedCategory(indexPath: indexPath, categories: self.stringCategories)
        dismiss(animated: true)
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
        newCategoryButton.setTitle("Добавить категорию", for: .normal)
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
        
        if stringCategories.count > 0 {
            var amount = 0
            for _ in 0..<stringCategories.count {
                amount += 74
            }
            tableView.constraints.first { constraint in
                constraint.firstAnchor == tableView.heightAnchor
            }?.isActive = false
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(amount)).isActive = true
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
