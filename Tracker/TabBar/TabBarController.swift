import UIKit

final class TabBarController: UITabBarController {
    var viewModel: TabBarViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = .ypWhite
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Controllers
        let trackerListVC = TrackersViewController()
        let statisticVC = StatisticViewController()
        let viewModels = viewModel?.getViewModels()
        trackerListVC.viewModel = viewModels?[0] as? TrackersViewModel
        statisticVC.viewModel = viewModels?[1] as? StatisticViewModel
        
        let navigationVC = UINavigationController(rootViewController: trackerListVC)
        
        // Images
        let trackerItemImage = UIImage(named: Constants.trackerListBarItem)?.withTintColor(.ypGray ?? .black)
        let trackerItemImageSelected = UIImage(named: Constants.trackerListBarItem)?.withTintColor(.ypBlue ?? .blue)
        let statisticItemImage = UIImage(named: Constants.statisticBarItem)?.withTintColor(.ypGray ?? .black)
        let statisticItemImageSelected = UIImage(named: Constants.statisticBarItem)?.withTintColor(.ypBlue ?? .blue)
        
        // Bar items for VC's
        trackerListVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                .localeKeys.trackers,
                comment: "Trackers bar item title"
            ),
            image: trackerItemImage,
            selectedImage: trackerItemImageSelected
        )
        statisticVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString(
                .localeKeys.statistic,
                comment: "Statistic bar item title"
            ),
            image: statisticItemImage,
            selectedImage: statisticItemImageSelected
        )
        
        trackerListVC.tabBarItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 10, weight: .medium)], for: .normal)
        statisticVC.tabBarItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 10, weight: .medium)], for: .normal)
        
        self.viewControllers = [navigationVC, statisticVC]
    }
}
