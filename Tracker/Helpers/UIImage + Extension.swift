import UIKit

extension UIImage {
    static let chevronLeft = UIImage(systemName: "chevron.left")!
    static let chevronRight = UIImage(systemName: "chevron.right")!
    static let xMark = UIImage(systemName: "xmark.circle.fill")!
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
