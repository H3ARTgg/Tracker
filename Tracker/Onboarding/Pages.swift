import UIKit

enum Pages: String, CaseIterable {
    case first = "Отслеживайте только то, что хотите"
    case second = "Даже если это не литры воды и йога"
    
    func getImage() -> UIImage {
        switch self {
        case .first:
            return UIImage(named: Constants.firstPageBG) ?? UIImage()
        case .second:
            return UIImage(named: Constants.secondPageBG) ?? UIImage()
        }
    }
    
    func next() -> Pages {
        switch self {
        case .first:
            return Pages.second
        case .second:
            return Pages.first
        }
    }
    
    func previous() -> Pages {
        switch self {
        case .first:
            return Pages.second
        case .second:
            return Pages.first
        }
    }
}
