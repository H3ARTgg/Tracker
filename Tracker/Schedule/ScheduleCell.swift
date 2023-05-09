import UIKit

final class ScheduleCell: UITableViewCell {
    weak var delegate: ScheduleCellDelegate?
    private let title = UILabel()
    private let switcher = UISwitch()
    private (set) var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ypBackground
        setupTitle()
        setupSwitcher()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTapSwitcher() {
        if let indexPath = getIndexPath() {
            if switcher.isOn {
                delegate?.choiceForDay(true, indexPath: indexPath)
            } else {
                delegate?.choiceForDay(false, indexPath: indexPath)
            }
        }
    }
    
    private func setupSwitcher() {
        switcher.addTarget(self, action: #selector(didTapSwitcher), for: .valueChanged)
        switcher.setOn(false, animated: false)
        switcher.onTintColor = .ypBlue
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(switcher)
        
        NSLayoutConstraint.activate([
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupTitle() {
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .ypBlack
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func getIndexPath() -> IndexPath? {
        guard let superview = self.superview as? UITableView else {
            assertionFailure("superview is not a UITableView - getIndexPath")
            return nil
        }
        indexPath = superview.indexPath(for: self)
        return indexPath
    }
    
    public func setTitle(with text: String) {
        self.title.text = text
    }
    
    public func setOn(_ state: Bool) {
        self.switcher.setOn(true, animated: false)
    }
}
