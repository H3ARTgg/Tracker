import UIKit

final class StatisticViewController: UIViewController {
    private let headerLabel = UILabel()
    private let trackersDoneView = UIView()
    private let trackersDoneCountLabel = UILabel()
    private let trackersDoneLabel = UILabel()
    private let noContentLabel = UILabel()
    private let noContentImageView = UIImageView()
    var viewModel: StatisticViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        guard let viewModel = viewModel else {
            return
        }

        setupHeaderLabel()
        
        if viewModel.recordCount == 0 {
            setupTitleAndImageIfNoContent(
                with: NSLocalizedString(.localeKeys.statisticNothing, comment: ""),
                label: noContentLabel,
                imageView: noContentImageView,
                image: .noStatistic
            )
        } else {
            setupTrackersDoneView()
        }
        
        viewModel.$recordCount.bind(action: { [weak self] recordCount in
            guard let self = self else { return }
            if recordCount != 0 {
                self.removeNoContent()
                self.setupTrackersDoneView()
                self.trackersDoneCountLabel.text = "\(recordCount)"
            } else {
                self.setupTitleAndImageIfNoContent(
                    with: NSLocalizedString(.localeKeys.statisticNothing, comment: ""),
                    label: self.noContentLabel,
                    imageView: self.noContentImageView,
                    image: .noStatistic
                )
                self.trackersDoneView.removeFromSuperview()
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        trackersDoneView.layer.borderColor = UIColor
            .makeGradient(with: trackersDoneView.bounds)
            .cgColor
    }
    
    private func removeNoContent() {
        noContentLabel.removeFromSuperview()
        noContentImageView.removeFromSuperview()
    }
}

// MARK: - Views
extension StatisticViewController {
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
