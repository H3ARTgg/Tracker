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
    var viewModel: OnboardingViewModel?
    
    override func viewDidLoad() {
        dataSource = self
        delegate = self
        setupButton()
        setupLayout()
        setViewControllers([PageSampleViewController(page: Pages.first)], direction: .forward, animated: true, completion: nil)
    }
    
    @objc private func didTapButton() {
        let tabBar = TabBarController(nibName: .none, bundle: .main)
        tabBar.modalPresentationStyle = .fullScreen
        tabBar.modalTransitionStyle = .crossDissolve
        tabBar.viewModel = viewModel?.getViewModelForTabBar()
        viewModel?.setOnboardingCompletion()
        dismiss(animated: true) { [weak self] in
            self?.present(tabBar, animated: true)
        }
    }
}

// MARK: - PageDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageSample = viewController as? PageSampleViewController else {
            return nil
        }
        
        let previousPage = pageSample.page.previous()
        
        return PageSampleViewController(page: previousPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageSample = viewController as? PageSampleViewController else {
            return nil
        }
        
        let nextPage = pageSample.page.next()
        
        return PageSampleViewController(page: nextPage)
    }
}

// MARK: - PageDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let pageSample = currentViewController as? PageSampleViewController,
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
