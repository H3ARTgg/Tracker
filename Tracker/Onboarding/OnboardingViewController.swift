import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var pages: [Pages] = Pages.allCases
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .onlyBlack
        pageControl.pageIndicatorTintColor = .ypGray
        
        return pageControl
    }()
    
    private var button = UIButton()
    
    override func viewDidLoad() {
        dataSource = self
        delegate = self
        setupButton()
        setupLayout()
        if let first = pages.first {
            setViewControllers([PageSample(page: first)], direction: .forward, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapButton() {
        Storage.addOnboardingCompletion()
        let tabBar = TabBarController(nibName: .none, bundle: .main)
        tabBar.modalPresentationStyle = .fullScreen
        tabBar.modalTransitionStyle = .crossDissolve
        dismiss(animated: true) { [weak self] in
            self?.present(tabBar, animated: true)
        }
    }
}

// MARK: - PageDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageSample = viewController as? PageSample else {
            return nil
        }
        
        guard let pageIndex = pages.firstIndex(of: pageSample.page) else {
            return nil
        }
        
        let previousIndex = pageIndex - 1
        
        guard previousIndex >= 0 else {
            return PageSample(page: pages[pages.count - 1])
        }
        
        return PageSample(page: pages[previousIndex])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageSample = viewController as? PageSample else {
            return nil
        }
        
        guard let pageIndex = pages.firstIndex(of: pageSample.page) else {
            return nil
        }
        
        let nextIndex = pageIndex + 1
        
        guard nextIndex < pages.count else {
            return PageSample(page: pages[pages.count - nextIndex])
        }
        
        return PageSample(page: pages[nextIndex])
    }
}

// MARK: - PageDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let pageSample = currentViewController as? PageSample,
           let currentIndex = pages.firstIndex(of: pageSample.page) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - Views
extension OnboardingViewController {
    private func setupButton() {
        button = UIButton.systemButton(with: .xMark, target: self, action: #selector(didTapButton))
        button.setImage(nil, for: .normal)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.makeCornerRadius(16)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .onlyBlack
    }
    
    private func setupLayout() {
        [button, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24)
        ])
    }
}
