import UIKit

extension UIViewController {
    func getTrackersViewController() -> UIViewController {
        if let presentingViewController = self.presentingViewController {
            return presentingViewController.getTrackersViewController()
        } else {
            if let tabBar = self as? UITabBarController,
                let navigation = tabBar.viewControllers?.first as? UINavigationController,
                let viewController = navigation.viewControllers.first {
                return viewController
            }
        }
        return self
    }
    
    func setupTitleLabel(with text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
        ])
    }
    
    func setupTitleAndImageIfNoContent(with text: String, label: UILabel, imageView: UIImageView) {
        label.textColor = .ypBlack
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        imageView.image = UIImage(named: Constants.noTrackersImage)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupScrollViewAndContentView(scrollView: UIScrollView, contentView: UIView, withExtraSpace: CGFloat? = nil) {
        var extraSpace: CGFloat = 0
        if let withExtraSpace = withExtraSpace {
            extraSpace += withExtraSpace
        }
        scrollView.bounces = true
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + extraSpace)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height + extraSpace)
        contentView.backgroundColor = .ypWhite
        scrollView.addSubview(contentView)
    }
}
