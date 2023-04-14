import UIKit

final class CategoriesViewController: UIViewController {
    private let cellIdentifier = "categoriesCell"
    private let tableView = UITableView()
    private var newCategoryButton = UIButton()
    var stringCategories: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let trackersVC = getTrackersViewController() as? TrackersViewController else {
            assertionFailure("No trackersVC")
            return
        }
        
        for category in trackersVC.categories {
            self.stringCategories.append(category.title)
        }
        
        if trackersVC.categories.isEmpty {
            self.setupTitleAndImageIfNoContent(with: "Привычки и события можно объединить по смыслу")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel(with: "Категория")
        setupNewCategoryButton()
    }
    
    @objc
    private func didTapNewCategoryButton() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.modalPresentationStyle = .popover
        present(newCategoryVC, animated: true)
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
        
        cell.title.text = stringCategories[indexPath.row]
        
        return cell
    }
    
    
}

// MARK: - TableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
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
        tableView.isScrollEnabled = false
        tableView.makeCornerRadius(16)
        tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        tableView.separatorColor = .ypGray
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypWhite
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
