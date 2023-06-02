import UIKit

final class HabitOrEventEmojiCell: UICollectionViewCell {
    let emoji = UILabel()
    private let mainView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .ypWhite
        contentView.makeCornerRadius(19)
        setupMainView()
        setupEmoji()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMainView() {
        mainView.backgroundColor = .ypWhite
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupEmoji() {
        emoji.font = .systemFont(ofSize: 36)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(emoji)
        
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: mainView.centerYAnchor)
        ])
    }
    
    func selectEmoji() {
        mainView.backgroundColor = .ypLightGray
    }
    
    func deselectEmoji() {
        mainView.backgroundColor = .ypWhite
    }
}
