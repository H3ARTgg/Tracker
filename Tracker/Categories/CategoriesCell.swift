import UIKit

// TODO: Переделать под MVVM
final class CategoriesCell: UITableViewCell {
    let title = UILabel()
    let imageViewForCheckmark = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .ypBackground
        
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeCheckmark() {
        imageViewForCheckmark.removeFromSuperview()
    }
    
    func setupCheckmark() {
        imageViewForCheckmark.image = UIImage(named: Constants.checkmark)!
        imageViewForCheckmark.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageViewForCheckmark)
        
        NSLayoutConstraint.activate([
            imageViewForCheckmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageViewForCheckmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
