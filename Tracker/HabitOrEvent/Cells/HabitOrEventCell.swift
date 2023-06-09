import UIKit

final class HabitOrEventCell: UITableViewCell {
    private let detailLabel = UILabel()
    let title = UILabel()
    var detailLabelText: String {
        get {
            if let text = detailLabel.text {
                return text
            } else {
                return ""
            }
        }
        set {
            setupDetailLabel()
            detailLabel.text = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .ypBackground
        setupTitle()
        
        let imageViewForArrow = UIImageView(image: UIImage(named: Constants.rightArrow)!)
        imageViewForArrow.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageViewForArrow)
        
        NSLayoutConstraint.activate([
            imageViewForArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageViewForArrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func setupDetailLabel() {
        detailLabel.font = .systemFont(ofSize: 17, weight: .regular)
        detailLabel.textColor = .ypGray
        detailLabel.textAlignment = .left
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        title.removeFromSuperview()

        contentView.addSubview(title)
        contentView.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3)
        ])
    }
    
    func removeDetailLabel() {
        detailLabel.removeFromSuperview()
        title.removeFromSuperview()
        setupTitle()
    }
}
