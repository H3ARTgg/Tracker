import UIKit
import Foundation

final class TrackersCell: UICollectionViewCell {
    private let daysLabel = UILabel()
    private let cardEmojiPlaceholder = UIView()
    private let cardView = UIView()
    private let cardText = UILabel()
    private let cardEmoji = UILabel()
    private let daysButton = UIButton()
    private var willDoubleTap: Bool = false
    private var selectionColor: UIColor? {
        didSet {
            daysButton.backgroundColor = selectionColor
            cardView.backgroundColor = selectionColor
        }
    }
    var viewModel: TrackersCellViewModel! {
        didSet {
            self.subviews.forEach { view in
                view.removeFromSuperview()
            }
            // В зависимости от номера ячейки меняются конcтрейнты
            setupCardViewFor(rowNumber: viewModel.rowNumber)
            setupCardEmojiPlaceholder()
            setupCardEmoji()
            setupCardText()
            setupDaysButton()
            setupDaysLabel()
            
            viewModel.$daysRecordText.bind { [weak self] text in
                self?.daysLabel.text = text
            }
            daysLabel.text = viewModel.daysRecordText
            
            selectionColor = viewModel.color
            cardText.text = viewModel.name
            cardEmoji.text = viewModel.emoji
            viewModel.isRecordExists ? setDone() : setNotDone()
            if viewModel.isDateBiggerThanRealTime() {
                daysButton.isUserInteractionEnabled = false
            } else {
                daysButton.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc
    private func addDay() {
        if !willDoubleTap {
            setDone()
            viewModel.didAddDay(true)
        } else {
            setNotDone()
            viewModel.didAddDay(false)
        }
    }
    
    /// Устанавливает состояние незавершенного трекера
    private func setNotDone() {
        daysButton.setImage(.plusForButton.imageResized(to: CGSize(width: 11, height: 11)), for: .normal)
        daysButton.layer.opacity = 1
        willDoubleTap = false
    }
    
    /// Устанавливает состояние завершенного трекера
    private func setDone() {
        willDoubleTap = true
        daysButton.layer.opacity = 0.5
        daysButton.setImage(.doneCheckmark.imageResized(to: CGSize(width: 11, height: 11)), for: .normal)
        daysButton.tintColor = .ypWhite
    }
    
    /// Получает текущий IndexPath ячейки
    private func getCurrentIndexPath() -> IndexPath {
        guard let superView = self.superview as? UICollectionView else {
            //assertionFailure("superview is not a UICollectionView - getIndexPath")
            return IndexPath(row: 0, section: 0)
        }
        return superView.indexPath(for: self) ?? IndexPath(row: 0, section: 0)
    }
}

// MARK: - Views
extension TrackersCell {
    private func setupCardViewFor(rowNumber: Int) {
        cardView.makeCornerRadius(16)
        cardView.backgroundColor = selectionColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        /*
         Если выставлять trailing и leading = 16 у collectionView, то скролл индикатор налазит на ячейки, в таком случае нужно менять констрейнты trailing и leading у ячейки, но..
         Если же по умолчанию ставить всем ячейкам leading и trailing = 16, то размер ячейки увеличивается на 32 и создает большой отступ между ячейками, что полностью убивает метод minimumInteritemSpacingForSectionAt.
         Данный способ помогает сохранить функциональность методов minimumInteritemSpacingForSectionAt и sizeForRowAt.
         Если есть иные решения, то буду рад узнать о них!
         */
        if rowNumber % 2 != 0 {
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
            cardText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            cardText.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            cardText.topAnchor.constraint(equalTo: cardEmojiPlaceholder.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDaysButton() {
        let plusImage = UIImage.plusForButton.imageResized(to: CGSize(width: 11, height: 11))
        daysButton.setImage(plusImage, for: .normal)
        daysButton.addTarget(self, action: #selector(addDay), for: .touchUpInside)
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

