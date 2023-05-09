import UIKit

extension UIView {
    func makeCornerRadius(_ amount: CGFloat) {
        self.layer.cornerRadius = amount
        self.layer.masksToBounds = true
    }
}
