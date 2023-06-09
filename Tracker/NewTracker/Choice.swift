enum Choice {
    case habit
    case event
    indirect case edit(Choice)
}
