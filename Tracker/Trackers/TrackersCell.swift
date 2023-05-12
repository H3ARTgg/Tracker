import UIKit
import Foundation

final class TrackersCell: UICollectionViewCell {
    private let daysLabel = UILabel()
    private let cardEmojiPlaceholder = UIView()
    private var daysButton = UIButton()
    private let cardView = UIView()
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var selectionColor: UIColor? {
        didSet {
            daysButton.backgroundColor = selectionColor
            cardView.backgroundColor = selectionColor
        }
    }
    private let cardText = UILabel()
    private let cardEmoji = UILabel()
    private var delegate: TrackersCellDelegate?
    private var daysCounter: Int = 0 {
        didSet {
            let lastInt = Int(String(String(daysCounter).last!))
            if let int = lastInt, daysCounter < 11 || daysCounter > 20 {
                switch int {
                case 0:
                    daysLabel.text? = "\(daysCounter) дней"
                case 1:
                    daysLabel.text? = "\(daysCounter) день"
                case 2...4:
                    daysLabel.text? = "\(daysCounter) дня"
                case 5...9:
                    daysLabel.text? = "\(daysCounter) дней"
                default:
                    daysLabel.text? = "\(daysCounter) дней"
                }
            } else {
                daysLabel.text? = "\(daysCounter) дней"
            }
        }
    }
    private var willDoubleTap: Bool = false
    private var id = UUID()
    
    @objc
    private func addDay() {
        if !willDoubleTap {
            setDone()
            daysCounter += 1
            delegate?.didRecieveNewRecord(true, for: id)
        } else {
            setNotDone()
            daysCounter -= 1
            delegate?.didRecieveNewRecord(false, for: id)
        }
    }
    
    private func setNotDone() {
        daysButton.setImage(.plusForButton.imageResized(to: CGSize(width: 11, height: 11)), for: .normal)
        daysButton.layer.opacity = 1
        willDoubleTap = false
    }
    
    private func setDone() {
        willDoubleTap = true
        daysButton.layer.opacity = 0.5
        daysButton.setImage(.doneCheckmark.imageResized(to: CGSize(width: 11, height: 11)), for: .normal)
        daysButton.tintColor = .ypWhite
    }
    
    func configCell(
        delegate: TrackersCellDelegate,
        id: UUID,
        color: UIColor,
        trackerName: String,
        emoji: String,
        daysCount: Int,
        isRecordExists: Bool,
        currentDate: Date,
        indexPath: IndexPath
    ) {
        self.indexPath = indexPath
        // Убрал из инициализации, так как констрейнты у меня настраиваются в зависимости от четности indexPath.row.
        // Потому что если выставлять trailing и leading = 16 у collectionView, то скролл индикатор налазит на ячейки, в таком случае trailing и leading будут меняться у констрейнтов самой ячейки (но и тут была проблема, объяснено ниже)
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        setupCardView()
        setupCardEmojiPlaceholder()
        setupCardEmoji()
        setupCardText()
        setupDaysButton()
        setupDaysLabel()
        
        self.id = id
        self.delegate = delegate
        self.selectionColor = color
        self.cardText.text = trackerName
        self.cardEmoji.text = emoji
        daysCounter = daysCount
        isRecordExists ? setDone() : setNotDone()
        if currentDate.isBiggerThanRealTime() {
            daysButton.isUserInteractionEnabled = false
        } else {
            daysButton.isUserInteractionEnabled = true
        }
        
    }
}

// MARK: - Views

extension TrackersCell {
    private func setupCardView() {
        cardView.makeCornerRadius(16)
        cardView.backgroundColor = selectionColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        
        // Данный способ помогает сохранить функциональность методов minimumInteritemSpacingForSectionAt и sizeForRowAt.
        // Если же по умолчанию ставить всем ячейкам leading и trailing = 16, то размер ячейки увеличивается на 32 и создает большой отступ между ячейками.
        if indexPath.row % 2 == 0 {
            if let contraint = cardView.constraints.first(where: { constraint in
                constraint.firstAnchor == cardView.leadingAnchor
            }) {
                contraint.isActive = false
            }
            NSLayoutConstraint.activate([
                cardView.topAnchor.constraint(equalTo: topAnchor),
                cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
            ])
        } else {
            NSLayoutConstraint.activate([
                cardView.topAnchor.constraint(equalTo: topAnchor),
                cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ])
        }
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
        let plusImage = UIImage.plusForButton.imageResized(to: CGSize(width: 11, height: 11))
        daysButton = UIButton.systemButton(with: plusImage, target: self, action: #selector(addDay))
        daysButton.tintColor = .ypWhite
        daysButton.translatesAutoresizingMaskIntoConstraints = false
        daysButton.backgroundColor = selectionColor ?? UIColor.white
        daysButton.titleLabel?.text = ""
        daysButton.makeCornerRadius(17)
        
        addSubview(daysButton)
        NSLayoutConstraint.activate([
            daysButton.widthAnchor.constraint(equalToConstant: 34),
            daysButton.heightAnchor.constraint(equalToConstant: 34),
            daysButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            daysButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            daysButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupDaysLabel() {
        daysLabel.numberOfLines = 1
        daysLabel.text = "0 дней"
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .ypBlack
        addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: daysButton.centerYAnchor),
            daysLabel.trailingAnchor.constraint(equalTo: daysButton.leadingAnchor, constant: 8)
        ])
    }
}

