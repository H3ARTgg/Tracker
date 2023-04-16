import UIKit

final class NewCategoryViewController: UIViewController {
    private let placeholderString = "Введите название категории"
    private let textField = UITextField()
    private var doneButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupTitleLabel(with: "Новая категория")
        setupTextField()
        setupDoneButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc
    private func didTapDoneButton() {
        guard let text = textField.text else { return }
        weak var categoriesVC = self.presentingViewController as? CategoriesViewController
        categoriesVC?.addNewCategory(category: text)
        dismiss(animated: true)
    }
}

// MARK: - TextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            let result = updatedText.count <= 25
            if updatedText.count == 0 {
                deactivateDoneButton()
            } else {
                activateDoneButton()
            }
            return result
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = nil
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        deactivateDoneButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - Views

extension NewCategoryViewController {
    private func setupTextField() {
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
        textField.setPaddingFor(left: 16)
        textField.clearButtonMode = .always
        textField.rightView?.isHidden = true
        textField.backgroundColor = .ypBackground
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.makeCornerRadius(16)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDoneButton() {
        doneButton = .systemButton(with: .chevronLeft, target: self, action: #selector(didTapDoneButton))
        doneButton.isUserInteractionEnabled = false
        doneButton.setImage(nil, for: .normal)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypBlack, for: .normal)
        doneButton.backgroundColor = .ypGray
        doneButton.titleLabel?.textAlignment = .center
        doneButton.makeCornerRadius(16)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    private func activateDoneButton() {
        doneButton.isUserInteractionEnabled = true
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.backgroundColor = .ypBlack
    }
    
    private func deactivateDoneButton() {
        doneButton.isUserInteractionEnabled = false
        doneButton.setTitleColor(.ypBlack, for: .normal)
        doneButton.backgroundColor = .ypGray
    }
}
