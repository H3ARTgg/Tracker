import UIKit

extension UIImage {
    static let chevronLeft = UIImage(systemName: "chevron.left") ?? UIImage()
    static let chevronRight = UIImage(systemName: "chevron.right") ?? UIImage()
    static let xMark = UIImage(systemName: "xmark.circle.fill") ?? UIImage()
    static let noTrackers = UIImage(named: Constants.noTrackersImage) ?? UIImage()
    static let noResult = UIImage(named: Constants.noResultImage) ?? UIImage()
    static let plusForButton = UIImage(named: Constants.plusBarItem) ?? UIImage()
    static let doneCheckmark = UIImage(named: "done_checkmark") ?? UIImage()
    static let minusForButton = UIImage(systemName: "minus") ?? UIImage()
    
    func imageResized(to size: CGSize, color: UIColor? = .ypWhite) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return image.withTintColor(color ?? .white, renderingMode: .automatic)
    }
    
    static func gradientImage(bounds: CGRect, colors: [CGColor], locations: [NSNumber]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
