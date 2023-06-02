import UIKit

extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel?.choice {
        case .habit:
            return 2
        case .event:
            return 1
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as? HabitOrEventCell else {
            assertionFailure("No habitEventCell")
            return UITableViewCell(frame: .zero)
        }
        
        cell.title.text = cellsStrings[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
}
