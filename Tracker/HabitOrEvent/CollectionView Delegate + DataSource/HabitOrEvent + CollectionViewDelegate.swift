import UIKit

extension HabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width / 6 - 5, height: 52)
        } else {
            return CGSize(width: collectionView.bounds.width / 6 - 6, height: 52)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 5
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView
            .systemLayoutSizeFitting(
                CGSize(
                    width: collectionView.frame.width,
                    height: UIView.layoutFittingExpandedSize.height
                ),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HabitOrEventEmojiCell else {
                assertionFailure("No cell for indexPath: \(indexPath)")
                return
            }
            checkForSelectedEmoji()
            cell.selectEmoji()
            selectedEmoji = indexPath
            isReadyForCreate()
        }
        else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HabitOrEventColorCell else {
                assertionFailure("No cell for indexPath: \(indexPath)")
                return
            }
            checkForSelectedColor()
            cell.selectColor()
            selectedColor = indexPath
            isReadyForCreate()
        }
    }
    
    private func checkForSelectedColor() {
        if let selectedColor = selectedColor {
            guard let selectedCell = collectionView.cellForItem(at: selectedColor) as? HabitOrEventColorCell else {
                assertionFailure("No cell for selected indexPath: \(selectedColor)")
                return
            }
            selectedCell.deselectColor()
        }
    }
    
    private func checkForSelectedEmoji() {
        if let selectedEmoji = selectedEmoji {
            guard let selectedCell = collectionView.cellForItem(at: selectedEmoji) as? HabitOrEventEmojiCell else {
                assertionFailure("No cell for selected indexPath: \(selectedEmoji)")
                return
            }
            selectedCell.deselectEmoji()
        }
    }
}
