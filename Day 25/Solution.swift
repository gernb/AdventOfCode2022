//
//  Solution.swift
//  Day 25
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Digits: Character {
    case two = "2"
    case one = "1"
    case zero = "0"
    case minus = "-"
    case doubleMinus = "="

    var value: Int {
        switch self {
        case .two: return 2
        case .one: return 1
        case .zero: return 0
        case .minus: return -1
        case .doubleMinus: return -2
        }
    }
}

func pow(_ base: Int, _ power: Int) -> Int {
    if power == 0 { return 1 }
    if power == 1 { return base }
    return (2...power).reduce(base, { result, _ in result * base })
}

func snafuToInt(_ value: String) -> Int {
    value.reversed().enumerated().reduce(0) {
        $0 + Digits(rawValue: $1.element)!.value * pow(5, $1.offset)
    }
}

func intToSnafu(_ value: Int) -> String {
    if value == 0 {
        return "0"
    }
    var value = value
    var result: [Digits] = []
    while value > 0 {
        var (q, r) = value.quotientAndRemainder(dividingBy: 5)
        switch r {
        case 0: result.append(.zero)
        case 1: result.append(.one)
        case 2: result.append(.two)
        case 3:
            result.append(.doubleMinus)
            q += 1
        case 4:
            result.append(.minus)
            q += 1
        default:
            fatalError()
        }
        value = q
    }
    return String(result.reversed().map(\.rawValue))
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let values = source.lines.map(snafuToInt(_:))
        let sum = values.reduce(0, +)
        let result = intToSnafu(sum)

        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        print("Part 2 (\(source)): Merry Christmas!")
    }
}
