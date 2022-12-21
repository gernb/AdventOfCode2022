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

extension ClosedRange where Bound == Int {
    var halves: (lower: ClosedRange, upper: ClosedRange) {
        assert(count >= 2)
        let mid = lowerBound + count / 2
        return (lowerBound ... mid - 1, mid ... upperBound)
    }
}

func find(_ value: Int, in range: ClosedRange<Int>, using valueFor: (Int) -> Int) -> Int {
    let halves = range.halves
    for newRange in [halves.lower, halves.upper] {
        let lower = valueFor(newRange.lowerBound)
        if lower == value {
            return newRange.lowerBound
        }
        let upper = valueFor(newRange.upperBound)
        if upper == value {
            return newRange.upperBound
        }

        if (min(lower, upper) ... max(lower, upper)).contains(value) {
            // It seems like there are multiple input values that can generate the output value.
            // So let's find the _lowest_ one that works.
            if newRange.count < 30 {
                for v in newRange {
                    if valueFor(v) == value {
                        return v
                    }
                }
            } else {
                return find(value, in: newRange, using: valueFor)
            }
        }
    }
    fatalError()
}

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

        let lower = 0
        let upper = Int.max / 100 // Avoid arithmetic overflow

        let valueToYell = find(valueToFind, in: lower ... upper) {
            jobs["humn"] = .yell($0)
            return performJob(for: unknown)
        }

        print("Part 2 (\(source)): \(valueToYell)")
    }
}
