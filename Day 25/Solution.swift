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

    init?(value: Int) {
        switch value {
        case 0: self = .zero
        case 1: self = .one
        case 2: self = .two
        case 3: self = .doubleMinus
        case 4: self = .minus
        default: return nil
        }
    }
}

func snafuToInt(_ value: String) -> Int {
    value.reduce(0) {
        $0 * 5 + Digits(rawValue: $1)!.value
    }
}

func intToSnafu(_ value: Int) -> String {
    if value == 0 {
        return "0"
    }
    var value = value
    var result: [Digits] = []
    while value > 0 {
        let (q, r) = value.quotientAndRemainder(dividingBy: 5)
        result.append(Digits(value: r)!)
        value = r > 2 ? q + 1 : q
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
