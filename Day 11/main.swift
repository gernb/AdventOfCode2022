//
//  main.swift
//  Day 11
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Operation {
    case add(Int)
    case multiply(Int)
    case square

    init(line: String) {
        let parts = line.components(separatedBy: " ")
        assert(parts[0] == "Operation:")
        assert(parts[1] == "new")
        assert(parts[2] == "=")
        assert(parts[3] == "old")
        if parts[4] == "*" && parts[5] == "old" {
            self = .square
        } else {
            let value = Int(parts[5])!
            switch parts[4] {
            case "+": self = .add(value)
            case "*": self = .multiply(value)
            default: fatalError()
            }
        }
    }

    func execute(with value: Int) -> Int {
        switch self {
        case .add(let amount): return value + amount
        case .multiply(let amount): return value * amount
        case .square: return value * value
        }
    }
}

final class Monkey {
    let id: Int
    var items: [Int]
    let operation: Operation
    let test: Int
    let testTrue: Int
    let testFalse: Int

    var inspectionCount = 0

    init(lines: [String]) {
        assert(lines.count == 6)
        self.id = { line in
            let id = line.components(separatedBy: " ").last!.dropLast()
            return Int(String(id))!
        }(lines[0].trimmingCharacters(in: .whitespaces))
        self.items = { line in
            let items = line.components(separatedBy: ":").last!.trimmingCharacters(in: .whitespaces)
            return items.components(separatedBy: ", ").map { Int($0)! }
        }(lines[1].trimmingCharacters(in: .whitespaces))
        self.operation = .init(line: lines[2].trimmingCharacters(in: .whitespaces))
        self.test = Int(lines[3].components(separatedBy: " ").last!)!
        self.testTrue = Int(lines[4].components(separatedBy: " ").last!)!
        self.testFalse = Int(lines[5].components(separatedBy: " ").last!)!
    }

    func turn(with monkeys: [Monkey]) {
        while items.isEmpty == false {
            inspectionCount += 1
            var item = items.removeFirst()
            item = operation.execute(with: item) / 3
            let id = item % test == 0 ? testTrue : testFalse
            let destination = monkeys.first { $0.id == id }!
            destination.items.append(item)
        }
    }
}

// MARK: - Part 1

print("Day 11:")

enum Part1 {
    static func run(_ source: InputData) {
        let monkeys = source.data.split(separator: "")
            .map(Array.init)
            .map(Monkey.init(lines:))

        for _ in 1 ... 20 {
            monkeys.forEach { monkey in
                monkey.turn(with: monkeys)
            }
        }

        let top2 = monkeys.map(\.inspectionCount).sorted(by: >).prefix(2)

        print("Part 1 (\(source)): \(top2[0] * top2[1])")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

extension Monkey {
    func turn2(with monkeys: [Monkey], magicNumber: Int) {
        while items.isEmpty == false {
            inspectionCount += 1
            var item = items.removeFirst()
            item = item % magicNumber
            item = operation.execute(with: item)
            let id = item % test == 0 ? testTrue : testFalse
            let destination = monkeys.first { $0.id == id }!
            destination.items.append(item)
        }
    }
}

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let monkeys = source.data.split(separator: "")
            .map(Array.init)
            .map(Monkey.init(lines:))

        let magicNumber = monkeys.map(\.test).reduce(1, *)

        for _ in 1 ... 10_000 {
            monkeys.forEach { monkey in
                monkey.turn2(with: monkeys, magicNumber: magicNumber)
            }
        }

        let top2 = monkeys.map(\.inspectionCount).sorted(by: >).prefix(2)

        print("Part 2 (\(source)): \(top2[0] * top2[1])")
    }
}

InputData.allCases.forEach(Part2.run)
