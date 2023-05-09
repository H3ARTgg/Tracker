import UIKit

final class HabitOrEventColorCell: UICollectionViewCell {
    let colorView = UIView()
    private let border = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .ypWhite
        setupColorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupColorView() {
        colorView.makeCornerRadius(8)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    func selectColor() {
        border.image = UIImage(named: Constants.selectBorder)!.withTintColor(colorView.backgroundColor!)
        border.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(border)
        
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            border.topAnchor.constraint(equalTo: contentView.topAnchor),
            border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func deselectColor() {
        border.removeFromSuperview()
    }
}
