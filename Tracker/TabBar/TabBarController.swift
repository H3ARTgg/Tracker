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
        trackerListVC.viewModel = viewModel?.getViewModelForTrackers()
        let statisticVC = StatisticViewController()
        let navigationVC = UINavigationController(rootViewController: trackerListVC)
        
        // Images
        let trackerItemImage = UIImage(named: Constants.trackerListBarItem)?.withTintColor(.ypGray ?? .black)
        let trackerItemImageSelected = UIImage(named: Constants.trackerListBarItem)?.withTintColor(.ypBlue ?? .blue)
        let statisticItemImage = UIImage(named: Constants.statisticBarItem)?.withTintColor(.ypGray ?? .black)
        let statisticItemImageSelected = UIImage(named: Constants.statisticBarItem)?.withTintColor(.ypBlue ?? .blue)
        
        // Bar items for VC's
        trackerListVC.tabBarItem = UITabBarItem(title: "Трекеры", image: trackerItemImage, selectedImage: trackerItemImageSelected)
        trackerListVC.tabBarItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 10, weight: .medium)], for: .normal)
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика", image: statisticItemImage, selectedImage: statisticItemImageSelected)
        statisticVC.tabBarItem.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 10, weight: .medium)], for: .normal)
        
        self.viewControllers = [navigationVC, statisticVC]
    }
}
