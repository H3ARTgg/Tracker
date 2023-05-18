public enum DaysOfTheWeek: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    /// Возвращает правильное склонение "дней" в зависимости от числа
    static func getRightTextDeclinationFor(recordCount: Int) -> String {
        let lastInt = Int(String(String(recordCount).last!))
        if let int = lastInt, recordCount < 11 || recordCount > 20 {
            switch int {
            case 0:
                return "\(recordCount) дней"
            case 1:
                return "\(recordCount) день"
            case 2...4:
                return "\(recordCount) дня"
            case 5...9:
                return "\(recordCount) дней"
            default:
                return "\(recordCount) дней"
            }
        } else {
            return "\(recordCount) дней"
        }
    }
}
