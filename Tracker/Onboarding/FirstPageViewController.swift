import UIKit

final class FirstPageViewController: UIViewController {
    private let imageView = UIImageView()
    private let label = UILabel()
    private var button = UIButton()
    
    override func viewDidLoad() {
        setupImageView()
        setupLabel()
    }
    
    private func setupImageView() {
        if let image = UIImage(named: Constants.firstPageBG) {
            imageView.image = image
        } else {
            assertionFailure("no image")
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLabel() {
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.text = "Отслеживайте только то, что хотите"
        label.numberOfLines = 2
        label.textColor = .onlyBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 400)
        ])
    }
}
