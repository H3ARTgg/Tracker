import UIKit

final class StatisticViewController: UIViewController {
    private let headerLabel = UILabel()
    private let trackersDoneView = UIView()
    private let trackersDoneCountLabel = UILabel()
    private let trackersDoneLabel = UILabel()
    var viewModel: StatisticViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupHeaderLabel()
        setupTrackersDoneView()
        
        viewModel?.$recordCount.bind(action: { [weak self] recordCount in
            self?.trackersDoneCountLabel.text = "\(recordCount)"
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        trackersDoneView.layer.borderColor = makeGradientColor().cgColor
    }
}

// MARK: - Views
extension StatisticViewController {
    private func makeGradientColor() -> UIColor {
        let color1 = CGColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
        let color2 = CGColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1)
        let color3 = CGColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1)
        let colors = [color3, color2, color1]
        let locations: [NSNumber] = [0.2, 0.5, 1.0]
        let gradient = UIImage.gradientImage(bounds: trackersDoneView.bounds, colors: colors, locations: locations)
        return UIColor(patternImage: gradient)
    }
    
    private func setupHeaderLabel() {
        headerLabel.text = NSLocalizedString(.localeKeys.statistic, comment: "Statistic header")
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 41)
        ])
    }
    
    private func setupTrackersDoneView() {
        trackersDoneView.backgroundColor = .ypWhite
        trackersDoneView.makeCornerRadius(16)
        trackersDoneView.layer.borderWidth = 1
        
        trackersDoneCountLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackersDoneCountLabel.textColor = .ypBlack
        trackersDoneCountLabel.text = "\(viewModel?.recordCount ?? 0)"
        
        trackersDoneLabel.font = .systemFont(ofSize: 12, weight: .medium)
        trackersDoneLabel.textColor = .ypBlack
        trackersDoneLabel.text = NSLocalizedString(.localeKeys.trackersCompleted, comment: "")
        
        [trackersDoneView, trackersDoneLabel, trackersDoneCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        trackersDoneView.addSubview(trackersDoneCountLabel)
        trackersDoneView.addSubview(trackersDoneLabel)
        view.addSubview(trackersDoneView)
        
        
        NSLayoutConstraint.activate([
            trackersDoneView.heightAnchor.constraint(equalToConstant: 90),
            trackersDoneView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersDoneView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersDoneView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 77),
            
            trackersDoneCountLabel.leadingAnchor.constraint(equalTo: trackersDoneView.leadingAnchor, constant: 12),
            trackersDoneCountLabel.trailingAnchor.constraint(equalTo: trackersDoneView.trailingAnchor, constant: -12),
            trackersDoneCountLabel.topAnchor.constraint(equalTo: trackersDoneView.topAnchor, constant: 12),
            
            trackersDoneLabel.leadingAnchor.constraint(equalTo: trackersDoneView.leadingAnchor, constant: 12),
            trackersDoneLabel.trailingAnchor.constraint(equalTo: trackersDoneView.trailingAnchor, constant: -12),
            trackersDoneLabel.bottomAnchor.constraint(equalTo: trackersDoneView.bottomAnchor, constant: -12)
        ])
        
    }
}
