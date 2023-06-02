import UIKit

extension UIImage {
    static let chevronLeft = UIImage(systemName: "chevron.left")!
    static let chevronRight = UIImage(systemName: "chevron.right")!
    static let xMark = UIImage(systemName: "xmark.circle.fill")!
    static let noTrackers = UIImage(named: Constants.noTrackersImage)!
    static let noResult = UIImage(named: Constants.noResultImage)!
    static let plusForButton = UIImage(named: Constants.plusBarItem)!
    static let doneCheckmark = UIImage(named: "done_checkmark")!
    
    func imageResized(to size: CGSize, color: UIColor? = .ypWhite) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return image.withTintColor(color ?? .white, renderingMode: .automatic)
    }
}
