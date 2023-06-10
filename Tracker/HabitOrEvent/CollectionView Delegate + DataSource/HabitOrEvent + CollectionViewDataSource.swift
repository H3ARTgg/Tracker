import UIKit

extension HabitOrEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return String.emojisArray.count
        } else {
            return UIColor.selectionColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as? HabitOrEventEmojiCell else {
                assertionFailure("No collection cell for that identifier")
                return UICollectionViewCell(frame: .zero)
            }
            
            viewModel?.configure(cell, with: indexPath)
            return cell
        } else {
            collectionView.register(HabitOrEventColorCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as? HabitOrEventColorCell else {
                assertionFailure("No collection cell for that identifier")
                return UICollectionViewCell(frame: .zero)
            }
            viewModel?.configure(cell, with: indexPath)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "Header"
        case UICollectionView.elementKindSectionFooter:
            id = "Footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? HabitOrEventSupplementaryView else {
            assertionFailure("No SupplementaryView")
            return UICollectionReusableView(frame: .zero)
        }
        if indexPath.section == 0 {
            view.titleLabel.text = NSLocalizedString(.localeKeys.emoji, comment: "Header for emojis")
        } else {
            view.titleLabel.text = NSLocalizedString(.localeKeys.color, comment: "Header for colors")
        }
        return view
    }
}
