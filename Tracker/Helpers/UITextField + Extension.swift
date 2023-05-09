import UIKit

extension UITextField {
    func setPaddingFor(left leftAmount: CGFloat? = nil, right rightAmount: CGFloat? = nil) {
        guard leftAmount != nil || rightAmount != nil else { return }
        
        if let leftAmount = leftAmount {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftAmount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        
        if let rightAmount = rightAmount {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: rightAmount, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    func setXMarkButton(target: Any, action: Selector) {
        let button = UIButton.systemButton(with: .xMark, target: target, action: action)
        button.tintColor = .ypGray
        button.frame = CGRect(x: 0, y: 0, width: 17 + 24, height: 17)
        button.bounds = CGRect(x: 0, y: 0, width: 17, height: 17)
        self.setPaddingFor(right: 100)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 17),
            button.widthAnchor.constraint(equalToConstant: 17),
        ])
        self.rightView = button
        self.rightViewMode = .whileEditing
    }
    
}
