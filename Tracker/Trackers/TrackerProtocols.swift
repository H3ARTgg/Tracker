import UIKit

protocol TrackersCellDelegate {
    func didRecieveNewRecord(_ completed: Bool, for id: UInt)
}
