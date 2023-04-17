import Foundation

extension Date {
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ components: [Calendar.Component], as date: Date) -> Bool {
        var results: [Bool] = []
        for component in components {
            results.append(distance(from: date, only: component) == 0)
        }
        return results.contains(false) ? false : true
    }
    
    /// Get weekday of date.
    func weekDay() -> Int {
        return Calendar.current.component(.weekday, from: self)
    }
}
