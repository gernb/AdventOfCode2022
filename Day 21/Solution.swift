//
//  Solution.swift
//  Day 21
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Operation {
    case add(String, String)
    case subtract(String, String)
    case multiply(String, String)
    case divide(String, String)
    case yell(Int)
}

typealias Jobs = [String: Operation]

// root: pppw + sjmn
func loadMonkeys(_ lines: [String]) -> Jobs {
    lines.reduce(into: Jobs()) { jobs, line in
        let parts = line.components(separatedBy: " ")
        let monkey = String(parts[0].dropLast())
        if let value = Int(parts[1]) {
            jobs[monkey] = .yell(value)
        } else {
            switch parts[2] {
            case "+": jobs[monkey] = .add(parts[1], parts[3])
            case "-": jobs[monkey] = .subtract(parts[1], parts[3])
            case "*": jobs[monkey] = .multiply(parts[1], parts[3])
            case "/": jobs[monkey] = .divide(parts[1], parts[3])
            default: fatalError()
            }
        }
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let jobs = loadMonkeys(source.lines)

        func performJob(for monkey: String) -> Int {
            let job = jobs[monkey]!
            switch job {
            case .yell(let value): return value
            case .add(let lhs, let rhs): return performJob(for: lhs) + performJob(for: rhs)
            case .subtract(let lhs, let rhs): return performJob(for: lhs) - performJob(for: rhs)
            case .multiply(let lhs, let rhs): return performJob(for: lhs) * performJob(for: rhs)
            case .divide(let lhs, let rhs): return performJob(for: lhs) / performJob(for: rhs)
            }
        }

        let root = performJob(for: "root")

        print("Part 1 (\(source)): \(root)")
    }
}

// MARK: - Part 2

extension Operation {
    var monkeys: [String] {
        switch self {
        case .yell: return []
        case .add(let lhs, let rhs): return [lhs, rhs]
        case .subtract(let lhs, let rhs): return [lhs, rhs]
        case .multiply(let lhs, let rhs): return [lhs, rhs]
        case .divide(let lhs, let rhs): return [lhs, rhs]
        }
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        var jobs = loadMonkeys(source.lines)

        func neededMonkeys(for monkey: String) -> Set<String> {
            let monkeys = jobs[monkey]!.monkeys
            return monkeys.reduce(Set(monkeys)) { $0.union(neededMonkeys(for: $1)) }
        }
        func performJob(for monkey: String) -> Int {
            let job = jobs[monkey]!
            switch job {
            case .yell(let value): return value
            case .add(let lhs, let rhs): return performJob(for: lhs) + performJob(for: rhs)
            case .subtract(let lhs, let rhs): return performJob(for: lhs) - performJob(for: rhs)
            case .multiply(let lhs, let rhs): return performJob(for: lhs) * performJob(for: rhs)
            case .divide(let lhs, let rhs): return performJob(for: lhs) / performJob(for: rhs)
            }
        }

        let rootMonkeys = jobs["root"]!.monkeys
        let unknown: String
        let valueToFind: Int
        if neededMonkeys(for: rootMonkeys[0]).contains("humn") {
            unknown = rootMonkeys[0]
            valueToFind = performJob(for: rootMonkeys[1])
        } else {
            unknown = rootMonkeys[1]
            valueToFind = performJob(for: rootMonkeys[0])
        }

        func find(_ value: Int, using calculate: (Int) -> Int) -> Int {
            var lower = 0
            var upper = Int.max / 100 // Avoid arithmetic overflow
            while (upper - lower) > 100 {
                let next = (upper - lower) / 2 + lower
                let result = calculate(next)
                if result == value {
                    return next
                }
                if source == .example {
                    // The example seems to increase as the number yelled increases
                    if result > value {
                        upper = next - 1
                    } else {
                        lower = next + 1
                    }
                } else {
                    // My challenge seems to decrease as the number yelled increases
                    if result < value {
                        upper = next - 1
                    } else {
                        lower = next + 1
                    }
                }
            }
            for next in lower ... upper {
                if calculate(next) == value {
                    return next
                }
            }
            fatalError()
        }

        let valueToYell = find(valueToFind) {
            jobs["humn"] = .yell($0)
            return performJob(for: unknown)
        }

        print("Part 2 (\(source)): \(valueToYell)")
    }
}
