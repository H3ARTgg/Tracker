struct WeekDay {
    let weekDay: Int
    let everyday: String = "Каждый день"
    /// Сокращенное название дня недели
    var shortName: String {
        switch weekDay {
        case 2:
            return "Пн"
        case 3:
            return "Вт"
        case 4:
            return "Ср"
        case 5:
            return "Чт"
        case 6:
            return "Пт"
        case 7:
            return "Сб"
        case 1:
            return "Вс"
        default:
            return "Каждый день"
        }
    }
    /// Длинное название дня недели
    var longName: String {
        switch weekDay {
        case 2:
            return "Понедельник"
        case 3:
            return "Вторник"
        case 4:
            return "Среда"
        case 5:
            return "Четверг"
        case 6:
            return "Пятница"
        case 7:
            return "Суббота"
        case 1:
            return "Воскресенье"
        default:
            return "Ошибка"
        }
    }
}
