import UIKit

extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel?.choice {
        case .habit:
            return 2
        case .event:
            return 1
        case .edit(let choice):
            switch choice {
            case .habit:
                return 2
            case .event:
                return 1
            case .edit(_):
                return 0
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as? HabitOrEventCell else {
            assertionFailure("No habitEventCell")
            return UITableViewCell(frame: .zero)
        }
        
        switch indexPath.row {
        case 0:
            cell.title.text = NSLocalizedString(.localeKeys.category, comment: "Text for Category cell")
        case 1:
            cell.title.text = NSLocalizedString(.localeKeys.schedule, comment: "Text for Schedule cell")
        default:
            cell.title.text = "Error"
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
}
