import UIKit

enum Choice: String {
    case habit = "Новая привычка"
    case event = "Новое нерегулярное событие"
}

protocol NewTrackerDelegate: AnyObject {}

final class NewTrackerViewController: UIViewController {
    private var habitButton = UIButton()
    private var eventButton = UIButton()
    private weak var delegate: NewTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupHabitAndEventButtons()
        setupTitleLabel(with: "Создание трекера")
    }
    
    required init(delegate: NewTrackerDelegate) {
        super.init(nibName: .none, bundle: .none)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTapHabitButton() {
        guard let habitOrEventDelegate = delegate as? HabitOrEventDelegate else {
            assertionFailure("NewTrackerDelegate isn't a HabitOrEventDelegate")
            return
        }
        let newHabitVC = HabitOrEventViewController(choice: .habit, delegate: habitOrEventDelegate)
        newHabitVC.modalPresentationStyle = .popover
        present(newHabitVC, animated: true)
    }
    
    @objc
    private func didTapEventButton() {
        guard let habitOrEventDelegate = delegate as? HabitOrEventDelegate else {
            assertionFailure("NewTrackerDelegate isn't a HabitOrEventDelegate")
            return
        }

        let newEventVC = HabitOrEventViewController(choice: .event, delegate: habitOrEventDelegate)
        newEventVC.modalPresentationStyle = .popover
        present(newEventVC, animated: true)
    }
}

// MARK: - Views

extension NewTrackerViewController {
    private func setupHabitAndEventButtons() {
        habitButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(didTapHabitButton))
        eventButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(didTapEventButton))
        
        habitButton.setTitle("Привычка", for: .normal)
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        
        setSettingForButton(habitButton)
        setSettingForButton(eventButton)
        
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func setSettingForButton(_ button: UIButton) {
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setImage(nil, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.makeCornerRadius(16)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
}
