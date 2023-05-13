import UIKit

extension HabitOrEventViewController {
    func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = false
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        collectionView.register(HabitOrEventEmojiCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        collectionView.register(HabitOrEventSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.register(HabitOrEventCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.makeCornerRadius(16)
        tableView.separatorInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
        tableView.separatorColor = .ypGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tableView)
        
        switch choice {
        case .habit:
            tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        case .event:
            tableView.heightAnchor.constraint(equalToConstant: 73).isActive = true
        case .none:
            tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        }
        
        if contentView.subviews.contains(where: {$0 == warningLabel}) {
            tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 32).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24).isActive = true
        }
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    func setupWarningLabel() {
        warningLabel.font = .systemFont(ofSize: 17, weight: .regular)
        warningLabel.text = "Ограничение 38 символов"
        warningLabel.textColor = .ypRed
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
    }
    
    func setupTextField() {
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.ypGray!])
        textField.setPaddingFor(left: 16)
        textField.clearButtonMode = .always
        textField.backgroundColor = .ypBackground
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.makeCornerRadius(16)
        textField.addTarget(self, action: #selector(didInteractionWithTextField), for: .allEditingEvents)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func setupButtonsWithSelectorsFor(done: Selector, cancel: Selector, with stackView: UIStackView) {
        createButton = .systemButton(with: .xMark, target: self, action: done)
        createButton.isUserInteractionEnabled = false
        createButton.setImage(nil, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypBlack, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.makeCornerRadius(16)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = .systemButton(with: .xMark, target: self, action: cancel)
        cancelButton.setImage(nil, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.backgroundColor = .ypAlphaWhite
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = CGColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        cancelButton.makeCornerRadius(16)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
