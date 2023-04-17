import UIKit

final class TrackersCell: UICollectionViewCell {
    var selectionColor: UIColor? {
        didSet {
            daysButton.backgroundColor = selectionColor
            cardView.backgroundColor = selectionColor
        }
    }
    let cardView = UIView()
    let cardText = UILabel()
    let cardEmojiPlaceholder = UIView()
    let cardEmoji = UILabel()
    let daysLabel = UILabel()
    var daysButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCardView()
        setupCardEmojiPlaceholder()
        setupCardEmoji()
        setupCardText()
        setupDaysButton()
        setupDaysLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addDay() {
        
    }
}

// MARK: - Views

extension TrackersCell {
    private func setupCardView() {
        cardView.makeCornerRadius(16)
        cardView.backgroundColor = selectionColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    private func setupCardEmojiPlaceholder() {
        cardEmojiPlaceholder.backgroundColor = .white
        cardEmojiPlaceholder.alpha = 0.3
        cardEmojiPlaceholder.makeCornerRadius(12)
        cardEmojiPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardEmojiPlaceholder)
        
        NSLayoutConstraint.activate([
            cardEmojiPlaceholder.widthAnchor.constraint(equalToConstant: 24),
            cardEmojiPlaceholder.heightAnchor.constraint(equalToConstant: 24),
            cardEmojiPlaceholder.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            cardEmojiPlaceholder.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupCardEmoji() {
        cardEmoji.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardEmoji)
        cardEmoji.font = .systemFont(ofSize: 13)
        
        NSLayoutConstraint.activate([
            cardEmoji.centerYAnchor.constraint(equalTo: cardEmojiPlaceholder.centerYAnchor),
            cardEmoji.centerXAnchor.constraint(equalTo: cardEmojiPlaceholder.centerXAnchor)
        ])
    }
    
    private func setupCardText() {
        cardText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cardText.textColor = .white
        cardText.translatesAutoresizingMaskIntoConstraints = false
        cardText.numberOfLines = 2
        cardView.addSubview(cardText)
        
        NSLayoutConstraint.activate([
            cardText.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 12),
            cardText.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 12),
            cardText.topAnchor.constraint(equalTo: cardEmojiPlaceholder.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDaysButton() {
        let plusImage = UIImage(named: Constants.plusBarItem)?.imageResized(to: CGSize(width: 11, height: 11))
        daysButton = UIButton.systemButton(with: plusImage!, target: self, action: #selector(addDay))
        daysButton.tintColor = .ypWhite
        daysButton.translatesAutoresizingMaskIntoConstraints = false
        daysButton.backgroundColor = selectionColor ?? UIColor.white
        daysButton.titleLabel?.text = ""
        daysButton.makeCornerRadius(17)
        
        addSubview(daysButton)
        NSLayoutConstraint.activate([
            daysButton.widthAnchor.constraint(equalToConstant: 34),
            daysButton.heightAnchor.constraint(equalToConstant: 34),
            daysButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            daysButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            daysButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupDaysLabel() {
        daysLabel.numberOfLines = 1
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .ypBlack
        addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: daysButton.centerYAnchor),
            daysLabel.trailingAnchor.constraint(equalTo: daysButton.leadingAnchor, constant: 8)
        ])
    }
}

